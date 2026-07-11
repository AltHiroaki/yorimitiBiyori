import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../models/user_settings.dart';
import 'scheduled_notification_plan_store.dart';

const int dailyInvitationNotificationId = 4101;

/// 先行してスケジュールする日数。通知の発火時にアプリ側コードは走らないため、
/// アプリ起動時（applySettings 経由）に毎回この日数分を張り直す。
/// この日数以上アプリを一度も開かないと通知は止まる（既知の制約）。
const int scheduledNotificationDayCount = 7;
const String notificationPayloadSuggestion = 'open_suggestion';
const String notificationTitle = '暇な時間って存在しますか？';
const String notificationBody = '好きなことの中から、小さなよりみちを提案します。';

const String _androidChannelId = 'yorimiti_daily_invitation';
const String _androidChannelName = 'よりみちのきっかけ';
const String _androidChannelDescription = '空き時間によりみち提案を届ける通知';
const String _androidDefaultIcon = '@mipmap/ic_launcher';
const String _japanTimeZoneName = 'Asia/Tokyo';

typedef NotificationTapCallback = void Function(String? payload);

abstract class NotificationController {
  Future<void> initialize({NotificationTapCallback? onNotificationTap});

  Future<bool> requestPermission();

  Future<void> applySettings(UserSettings settings);

  Future<void> showInvitationNotification();

  Future<void> scheduleDailyNotifications({
    required String startTime,
    required String endTime,
  });

  Future<void> cancelDailyNotifications();
}

class DailyNotificationTime {
  const DailyNotificationTime({required this.hour, required this.minute});

  final int hour;
  final int minute;
}

DailyNotificationTime parseNotificationTime(
  String source, {
  String fallbackTime = defaultNotificationStartTime,
}) {
  final parts = source.split(':');
  if (parts.length != 2) {
    return parseNotificationTime(fallbackTime);
  }

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  final isValidTime = hour != null &&
      minute != null &&
      hour >= 0 &&
      hour <= 23 &&
      minute >= 0 &&
      minute <= 59;
  if (!isValidTime) {
    return parseNotificationTime(fallbackTime);
  }

  return DailyNotificationTime(hour: hour, minute: minute);
}

/// [dayCount] 日分の通知予定時刻を返す。各日 1 件、時間帯
/// [startTime]〜[endTime]（両端含む・分単位）のランダムな時刻を選ぶ。
/// startTime == endTime の縮退範囲は常にその時刻（固定時刻通知と同じ）。
///
/// 初日は今日。ただし以下の場合は明日から始める：
/// - [previousPlan] に「今日 かつ now 以前」の予定がある
///   （＝今日の通知は発火済みとみなす。同じ日に 2 回通知しないため）
/// - 今日の時間帯がすでに終わっている（now の次の分が endTime より後）
///
/// 初日が今日の場合、選ぶ時刻は必ず未来になるよう now の次の分を下限にする。
/// 未発火の予定は呼び出しのたびに乱択し直してよい（同じ通知 ID を
/// 上書きするので 1 日 1 件は保たれる）。
List<timezone.TZDateTime> computeNotificationSchedule({
  required timezone.Location location,
  required timezone.TZDateTime now,
  required DailyNotificationTime startTime,
  required DailyNotificationTime endTime,
  required math.Random random,
  List<timezone.TZDateTime> previousPlan = const [],
  int dayCount = scheduledNotificationDayCount,
}) {
  var startMinutes = startTime.hour * 60 + startTime.minute;
  var endMinutes = endTime.hour * 60 + endTime.minute;
  if (startMinutes > endMinutes) {
    // 保存データが壊れている場合の防御。デフォルトの時間帯に置き換える。
    final defaultStart = parseNotificationTime(defaultNotificationStartTime);
    final defaultEnd = parseNotificationTime(defaultNotificationEndTime);
    startMinutes = defaultStart.hour * 60 + defaultStart.minute;
    endMinutes = defaultEnd.hour * 60 + defaultEnd.minute;
  }

  final nowMinutes = now.hour * 60 + now.minute;
  final isTodayFired = previousPlan.any((scheduled) =>
      scheduled.year == now.year &&
      scheduled.month == now.month &&
      scheduled.day == now.day &&
      !scheduled.isAfter(now));
  final isTodayRangeOver = nowMinutes + 1 > endMinutes;
  final firstDayOffset = (isTodayFired || isTodayRangeOver) ? 1 : 0;

  final schedule = <timezone.TZDateTime>[];
  for (var i = 0; i < dayCount; i++) {
    final day = timezone.TZDateTime(
      location,
      now.year,
      now.month,
      now.day + firstDayOffset + i,
    );
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    final effectiveStartMinutes =
        isToday ? math.max(startMinutes, nowMinutes + 1) : startMinutes;
    final pickedMinutes = effectiveStartMinutes +
        random.nextInt(endMinutes - effectiveStartMinutes + 1);
    schedule.add(
      timezone.TZDateTime(
        location,
        day.year,
        day.month,
        day.day,
        pickedMinutes ~/ 60,
        pickedMinutes % 60,
      ),
    );
  }
  return schedule;
}

class NotificationService implements NotificationController {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    timezone.Location? location,
    timezone.TZDateTime Function()? now,
    math.Random? random,
    ScheduledNotificationPlanStore? planStore,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _location = location,
        _now = now,
        _random = random ?? math.Random(),
        _planStore = planStore ?? ScheduledNotificationPlanStore();

  final FlutterLocalNotificationsPlugin _plugin;
  final timezone.Location? _location;
  final timezone.TZDateTime Function()? _now;
  final math.Random _random;
  final ScheduledNotificationPlanStore _planStore;

  bool _isInitialized = false;
  NotificationTapCallback? _onNotificationTap;

  @override
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    _onNotificationTap = onNotificationTap ?? _onNotificationTap;
    if (_isInitialized) {
      return;
    }

    try {
      timezone_data.initializeTimeZones();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_androidDefaultIcon),
        ),
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      final launchResponse = launchDetails?.notificationResponse;
      if (launchDetails?.didNotificationLaunchApp == true &&
          launchResponse?.payload == notificationPayloadSuggestion) {
        _onNotificationTap?.call(launchResponse?.payload);
      }
      _isInitialized = true;
    } catch (error) {
      if (!_isNotificationPluginUnavailable(error)) {
        rethrow;
      }
      _isInitialized = true;
    }
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final isGranted = await androidPlugin?.requestNotificationsPermission();
      return isGranted ?? true;
    } catch (error) {
      if (!_isNotificationPluginUnavailable(error)) {
        rethrow;
      }
      return true;
    }
  }

  @override
  Future<void> applySettings(UserSettings settings) async {
    await initialize();
    if (!settings.notificationEnabled) {
      await cancelDailyNotifications();
      return;
    }
    await scheduleDailyNotifications(
      startTime: settings.notificationStartTime,
      endTime: settings.notificationEndTime,
    );
  }

  @override
  Future<void> showInvitationNotification() async {
    await initialize();
    try {
      await _plugin.show(
        id: dailyInvitationNotificationId,
        title: notificationTitle,
        body: notificationBody,
        notificationDetails: _notificationDetails,
        payload: notificationPayloadSuggestion,
      );
    } catch (error) {
      if (!_isNotificationPluginUnavailable(error)) {
        rethrow;
      }
      return;
    }
  }

  @override
  Future<void> scheduleDailyNotifications({
    required String startTime,
    required String endTime,
  }) async {
    await initialize();
    final location = _notificationLocation;
    final schedule = computeNotificationSchedule(
      location: location,
      now: _now?.call() ?? timezone.TZDateTime.now(location),
      startTime: parseNotificationTime(startTime),
      endTime: parseNotificationTime(
        endTime,
        fallbackTime: defaultNotificationEndTime,
      ),
      random: _random,
      previousPlan: await _planStore.load(location),
    );

    try {
      // 単発通知を日数分予約する（毎日リピートの matchDateTimeComponents は
      // 使わない。同時刻リピートではランダム化できないため）。
      for (var i = 0; i < schedule.length; i++) {
        await _plugin.zonedSchedule(
          id: dailyInvitationNotificationId + i,
          title: notificationTitle,
          body: notificationBody,
          scheduledDate: schedule[i],
          notificationDetails: _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: notificationPayloadSuggestion,
        );
      }
    } catch (error) {
      if (!_isNotificationPluginUnavailable(error)) {
        rethrow;
      }
    }
    await _planStore.save(schedule);
  }

  @override
  Future<void> cancelDailyNotifications() async {
    await initialize();
    try {
      for (var i = 0; i < scheduledNotificationDayCount; i++) {
        await _plugin.cancel(id: dailyInvitationNotificationId + i);
      }
    } catch (error) {
      if (!_isNotificationPluginUnavailable(error)) {
        rethrow;
      }
    }
    await _planStore.clear();
  }

  timezone.Location get _notificationLocation {
    timezone_data.initializeTimeZones();
    return _location ?? timezone.getLocation(_japanTimeZoneName);
  }

  NotificationDetails get _notificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.payload != notificationPayloadSuggestion) {
      return;
    }
    _onNotificationTap?.call(response.payload);
  }

  bool _isNotificationPluginUnavailable(Object error) {
    if (error is MissingPluginException) {
      return true;
    }

    // Widget tests do not register flutter_local_notifications' platform
    // singleton. The production Android app registers it through Flutter's
    // generated plugin registrant.
    final message = error.toString();
    return message.contains('LateInitializationError') &&
        message.contains('has not been initialized');
  }
}

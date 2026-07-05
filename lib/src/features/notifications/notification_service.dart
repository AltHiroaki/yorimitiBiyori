import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../models/user_settings.dart';

const int dailyInvitationNotificationId = 4101;
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

  Future<void> scheduleDailyNotification(String notificationTime);

  Future<void> cancelDailyNotification();
}

class DailyNotificationTime {
  const DailyNotificationTime({required this.hour, required this.minute});

  final int hour;
  final int minute;
}

DailyNotificationTime parseNotificationTime(String source) {
  final parts = source.split(':');
  if (parts.length != 2) {
    return parseNotificationTime(defaultNotificationTime);
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
    return parseNotificationTime(defaultNotificationTime);
  }

  return DailyNotificationTime(hour: hour, minute: minute);
}

timezone.TZDateTime nextDailyNotificationDate({
  required timezone.Location location,
  required timezone.TZDateTime now,
  required DailyNotificationTime notificationTime,
}) {
  var scheduledDate = timezone.TZDateTime(
    location,
    now.year,
    now.month,
    now.day,
    notificationTime.hour,
    notificationTime.minute,
  );
  if (!scheduledDate.isAfter(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

class NotificationService implements NotificationController {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    timezone.Location? location,
    timezone.TZDateTime Function()? now,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _location = location,
        _now = now;

  final FlutterLocalNotificationsPlugin _plugin;
  final timezone.Location? _location;
  final timezone.TZDateTime Function()? _now;

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
      await cancelDailyNotification();
      return;
    }
    await scheduleDailyNotification(settings.notificationTime);
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
  Future<void> scheduleDailyNotification(String notificationTime) async {
    await initialize();
    final parsedTime = parseNotificationTime(notificationTime);
    final location = _notificationLocation;
    final scheduledDate = nextDailyNotificationDate(
      location: location,
      now: _now?.call() ?? timezone.TZDateTime.now(location),
      notificationTime: parsedTime,
    );

    try {
      await _plugin.zonedSchedule(
        id: dailyInvitationNotificationId,
        title: notificationTitle,
        body: notificationBody,
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
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
  Future<void> cancelDailyNotification() async {
    await initialize();
    try {
      await _plugin.cancel(id: dailyInvitationNotificationId);
    } catch (error) {
      if (!_isNotificationPluginUnavailable(error)) {
        rethrow;
      }
      return;
    }
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

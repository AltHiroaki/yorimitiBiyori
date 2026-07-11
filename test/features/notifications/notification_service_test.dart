import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;
import 'package:yorimiti_biyori/src/features/notifications/notification_service.dart';

/// キューに積んだ値を順に返すスクリプト化 Random。
/// nextInt に渡された max も記録し、境界値のアサーションに使う。
class _ScriptedRandom implements math.Random {
  _ScriptedRandom(this._values);

  final List<int> _values;
  final List<int> receivedMaxValues = [];

  @override
  int nextInt(int max) {
    receivedMaxValues.add(max);
    if (_values.isEmpty) {
      return 0;
    }
    return _values.removeAt(0).clamp(0, max - 1);
  }

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

void main() {
  late timezone.Location location;

  setUpAll(() {
    timezone_data.initializeTimeZones();
    location = timezone.getLocation('Asia/Tokyo');
  });

  group('parseNotificationTime', () {
    test('HH:mm 形式の通知時刻をパースできる', () {
      final notificationTime = parseNotificationTime('08:05');

      expect(notificationTime.hour, 8);
      expect(notificationTime.minute, 5);
    });

    test('不正な通知時刻はデフォルトの開始時刻 17:00 にフォールバックする', () {
      final notificationTime = parseNotificationTime('25:99');

      expect(notificationTime.hour, 17);
      expect(notificationTime.minute, 0);
    });

    test('fallbackTime を指定するとその時刻にフォールバックする', () {
      final notificationTime =
          parseNotificationTime('bad', fallbackTime: '21:00');

      expect(notificationTime.hour, 21);
      expect(notificationTime.minute, 0);
    });
  });

  group('computeNotificationSchedule', () {
    const start = DailyNotificationTime(hour: 17, minute: 0);
    const end = DailyNotificationTime(hour: 21, minute: 0);

    test('7 日連続・各日 1 件・すべて時間帯の範囲内になる', () {
      final now = timezone.TZDateTime(location, 2026, 7, 12, 10);

      final schedule = computeNotificationSchedule(
        location: location,
        now: now,
        startTime: start,
        endTime: end,
        random: math.Random(42),
      );

      expect(schedule, hasLength(scheduledNotificationDayCount));
      for (var i = 0; i < schedule.length; i++) {
        final date = schedule[i];
        expect(date.day, 12 + i);
        final minutes = date.hour * 60 + date.minute;
        expect(minutes, inInclusiveRange(17 * 60, 21 * 60));
      }
    });

    test('now が時間帯より前なら初日は今日になる', () {
      final now = timezone.TZDateTime(location, 2026, 7, 12, 10);
      final random = _ScriptedRandom([0]);

      final schedule = computeNotificationSchedule(
        location: location,
        now: now,
        startTime: start,
        endTime: end,
        random: random,
      );

      expect(schedule.first.day, 12);
      expect(schedule.first.hour, 17);
      expect(schedule.first.minute, 0);
      // 今日はまだ範囲前なので下限は startTime のまま（span は 241 分）。
      expect(random.receivedMaxValues.first, 4 * 60 + 1);
    });

    test('now が時間帯の途中なら今日の下限は now の次の分になる', () {
      final now = timezone.TZDateTime(location, 2026, 7, 12, 19, 30);
      final random = _ScriptedRandom([0]);

      final schedule = computeNotificationSchedule(
        location: location,
        now: now,
        startTime: start,
        endTime: end,
        random: random,
      );

      expect(schedule.first.day, 12);
      expect(schedule.first.hour, 19);
      expect(schedule.first.minute, 31);
      // [19:31, 21:00] の 90 分間（両端含む）。
      expect(random.receivedMaxValues.first, 90);
    });

    test('random が最大値を返すと終了時刻ちょうどになる（上限を含む）', () {
      final now = timezone.TZDateTime(location, 2026, 7, 12, 10);
      final random = _ScriptedRandom([4 * 60]);

      final schedule = computeNotificationSchedule(
        location: location,
        now: now,
        startTime: start,
        endTime: end,
        random: random,
      );

      expect(schedule.first.hour, 21);
      expect(schedule.first.minute, 0);
    });

    test('今日の時間帯が終わっていれば初日は明日になる', () {
      final now = timezone.TZDateTime(location, 2026, 7, 12, 21, 0);

      final schedule = computeNotificationSchedule(
        location: location,
        now: now,
        startTime: start,
        endTime: end,
        random: math.Random(42),
      );

      expect(schedule.first.day, 13);
    });

    test('前回プランに今日の発火済み時刻があれば初日は明日になる', () {
      final now = timezone.TZDateTime(location, 2026, 7, 12, 19, 0);
      final firedToday = timezone.TZDateTime(location, 2026, 7, 12, 18, 15);

      final schedule = computeNotificationSchedule(
        location: location,
        now: now,
        startTime: start,
        endTime: end,
        random: math.Random(42),
        previousPlan: [firedToday],
      );

      expect(schedule.first.day, 13);
    });

    test('前回プランの今日分がまだ未来なら今日を乱択し直す', () {
      final now = timezone.TZDateTime(location, 2026, 7, 12, 18, 0);
      final pendingToday = timezone.TZDateTime(location, 2026, 7, 12, 20, 45);

      final schedule = computeNotificationSchedule(
        location: location,
        now: now,
        startTime: start,
        endTime: end,
        random: math.Random(42),
        previousPlan: [pendingToday],
      );

      expect(schedule.first.day, 12);
    });

    test('開始 == 終了の縮退範囲は常にその時刻になる（固定時刻通知）', () {
      final now = timezone.TZDateTime(location, 2026, 7, 12, 10);
      const fixedTime = DailyNotificationTime(hour: 17, minute: 30);

      final schedule = computeNotificationSchedule(
        location: location,
        now: now,
        startTime: fixedTime,
        endTime: fixedTime,
        random: math.Random(42),
      );

      for (final date in schedule) {
        expect(date.hour, 17);
        expect(date.minute, 30);
      }
    });

    test('開始 > 終了の壊れた範囲はデフォルトの 17:00〜21:00 に置き換える', () {
      final now = timezone.TZDateTime(location, 2026, 7, 12, 10);

      final schedule = computeNotificationSchedule(
        location: location,
        now: now,
        startTime: const DailyNotificationTime(hour: 22, minute: 0),
        endTime: const DailyNotificationTime(hour: 8, minute: 0),
        random: math.Random(42),
      );

      for (final date in schedule) {
        final minutes = date.hour * 60 + date.minute;
        expect(minutes, inInclusiveRange(17 * 60, 21 * 60));
      }
    });

    test('月末をまたいでも日付が正しく進む', () {
      final now = timezone.TZDateTime(location, 2026, 7, 29, 22, 0);

      final schedule = computeNotificationSchedule(
        location: location,
        now: now,
        startTime: start,
        endTime: end,
        random: math.Random(42),
      );

      // 22:00 は範囲終了後なので 7/30 から 7 日分。
      expect(schedule[0].month, 7);
      expect(schedule[0].day, 30);
      expect(schedule[2].month, 8);
      expect(schedule[2].day, 1);
    });
  });

  test('通知文言に分数を含めない', () {
    expect(notificationTitle, isNot(contains(RegExp(r'\d+\s*分'))));
    expect(notificationBody, isNot(contains(RegExp(r'\d+\s*分'))));
  });
}

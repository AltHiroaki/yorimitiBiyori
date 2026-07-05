import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;
import 'package:yorimiti_biyori/src/features/notifications/notification_service.dart';

void main() {
  setUpAll(timezone_data.initializeTimeZones);

  test('HH:mm 形式の通知時刻をパースできる', () {
    final notificationTime = parseNotificationTime('08:05');

    expect(notificationTime.hour, 8);
    expect(notificationTime.minute, 5);
  });

  test('不正な通知時刻はデフォルトの 17:30 にフォールバックする', () {
    final notificationTime = parseNotificationTime('25:99');

    expect(notificationTime.hour, 17);
    expect(notificationTime.minute, 30);
  });

  test('指定時刻がまだ先なら今日の通知時刻を返す', () {
    final location = timezone.getLocation('Asia/Tokyo');
    final now = timezone.TZDateTime(location, 2026, 7, 5, 10);

    final scheduledDate = nextDailyNotificationDate(
      location: location,
      now: now,
      notificationTime: const DailyNotificationTime(hour: 17, minute: 30),
    );

    expect(scheduledDate.year, 2026);
    expect(scheduledDate.month, 7);
    expect(scheduledDate.day, 5);
    expect(scheduledDate.hour, 17);
    expect(scheduledDate.minute, 30);
  });

  test('指定時刻を過ぎていれば翌日の通知時刻を返す', () {
    final location = timezone.getLocation('Asia/Tokyo');
    final now = timezone.TZDateTime(location, 2026, 7, 5, 18);

    final scheduledDate = nextDailyNotificationDate(
      location: location,
      now: now,
      notificationTime: const DailyNotificationTime(hour: 17, minute: 30),
    );

    expect(scheduledDate.year, 2026);
    expect(scheduledDate.month, 7);
    expect(scheduledDate.day, 6);
    expect(scheduledDate.hour, 17);
    expect(scheduledDate.minute, 30);
  });

  test('通知文言に分数を含めない', () {
    expect(notificationTitle, isNot(contains(RegExp(r'\d+\s*分'))));
    expect(notificationBody, isNot(contains(RegExp(r'\d+\s*分'))));
  });
}

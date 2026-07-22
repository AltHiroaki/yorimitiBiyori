import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;
import 'package:yorimichi_biyori/src/features/notifications/scheduled_notification_plan_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(timezone_data.initializeTimeZones);

  late timezone.Location location;

  setUp(() {
    location = timezone.getLocation('Asia/Tokyo');
  });

  test('保存したプランを読込で復元できる', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ScheduledNotificationPlanStore();
    final plan = [
      timezone.TZDateTime(location, 2026, 7, 12, 18, 30),
      timezone.TZDateTime(location, 2026, 7, 13, 20, 5),
    ];

    await store.save(plan);
    final loadedPlan = await store.load(location);

    expect(loadedPlan, plan);
  });

  test('未保存のときは空リストを返す', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ScheduledNotificationPlanStore();

    final loadedPlan = await store.load(location);

    expect(loadedPlan, isEmpty);
  });

  test('壊れた JSON は空リストへフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      scheduledNotificationPlanPreferenceKey: '{{not json',
    });
    final store = ScheduledNotificationPlanStore();

    final loadedPlan = await store.load(location);

    expect(loadedPlan, isEmpty);
  });

  test('配列以外の JSON・数値以外の要素は無視される', () async {
    SharedPreferences.setMockInitialValues({
      scheduledNotificationPlanPreferenceKey: '{"a": 1}',
    });
    final store = ScheduledNotificationPlanStore();

    expect(await store.load(location), isEmpty);

    SharedPreferences.setMockInitialValues({
      scheduledNotificationPlanPreferenceKey: '["x", 1752307800000]',
    });

    final loadedPlan = await store.load(location);
    expect(loadedPlan, hasLength(1));
  });

  test('clear でプランが破棄される', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ScheduledNotificationPlanStore();
    await store.save([timezone.TZDateTime(location, 2026, 7, 12, 18, 30)]);

    await store.clear();

    expect(await store.load(location), isEmpty);
  });
}

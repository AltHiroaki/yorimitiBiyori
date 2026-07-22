import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as timezone;

/// スケジュール済み通知プランの保存キー。
const String scheduledNotificationPlanPreferenceKey =
    'yorimichi_biyori_scheduled_notification_plan';

/// スケジュール済みの通知予定時刻を shared_preferences に保存・復元する store。
/// 値はエポックミリ秒の JSON 配列。Android には「通知が発火した」ことを知る
/// コールバックが無いため、「今日の予定時刻をもう過ぎているか」で発火済みを
/// 代理判定し、同じ日に 2 回目の通知を予約しないために使う。
class ScheduledNotificationPlanStore {
  /// 保存済みプランを読み込む。未保存・破損時は空リストへ安全フォールバックする。
  Future<List<timezone.TZDateTime>> load(timezone.Location location) async {
    final preferences = await SharedPreferences.getInstance();
    final source =
        preferences.getString(scheduledNotificationPlanPreferenceKey);
    if (source == null) {
      return const [];
    }

    try {
      final decodedJson = jsonDecode(source);
      if (decodedJson is! List) {
        return const [];
      }
      final plan = <timezone.TZDateTime>[];
      for (final value in decodedJson) {
        if (value is int) {
          plan.add(
            timezone.TZDateTime.fromMillisecondsSinceEpoch(location, value),
          );
        }
      }
      return plan;
    } on FormatException {
      return const [];
    }
  }

  /// プランを保存する。既存の保存内容は上書きされる。
  Future<void> save(List<timezone.TZDateTime> plan) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      scheduledNotificationPlanPreferenceKey,
      jsonEncode([for (final date in plan) date.millisecondsSinceEpoch]),
    );
  }

  /// プランを破棄する（通知 OFF 時に呼ぶ）。
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(scheduledNotificationPlanPreferenceKey);
  }
}

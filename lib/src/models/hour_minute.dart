/// 1日の中の時刻（時・分）を表す値オブジェクト。
/// `HH:mm` 文字列のパース・バリデーション・整形・分換算をここに集約する。
/// モデル・features・pages のどの層からも import できるよう純 Dart で実装する。
class HourMinute {
  const HourMinute({required this.hour, required this.minute});

  /// [dateTime] の時・分を取り出す（表示用整形などに使う）。
  HourMinute.fromDateTime(DateTime dateTime)
      : hour = dateTime.hour,
        minute = dateTime.minute;

  final int hour;
  final int minute;

  /// `HH:mm` 形式（hour 0〜23・minute 0〜59）として解釈できれば返す。
  /// 形式不正・範囲外は null。
  static HourMinute? tryParse(String source) {
    final parts = source.split(':');
    if (parts.length != 2) {
      return null;
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
      return null;
    }

    return HourMinute(hour: hour, minute: minute);
  }

  /// 0 時からの経過分。時刻同士の前後比較に使う。
  int get totalMinutes => hour * 60 + minute;

  /// ゼロ埋めした `HH:mm` 文字列（例：`08:05`）。
  String format() {
    final paddedHour = hour.toString().padLeft(2, '0');
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$paddedHour:$paddedMinute';
  }
}

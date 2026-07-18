import 'package:flutter_test/flutter_test.dart';
import 'package:yorimiti_biyori/src/models/hour_minute.dart';

void main() {
  group('HourMinute.tryParse', () {
    test('HH:mm 形式をパースできる', () {
      final time = HourMinute.tryParse('08:05');

      expect(time, isNotNull);
      expect(time!.hour, 8);
      expect(time.minute, 5);
    });

    test('ゼロ埋めなしの H:m 形式もパースできる', () {
      final time = HourMinute.tryParse('8:5');

      expect(time, isNotNull);
      expect(time!.hour, 8);
      expect(time.minute, 5);
    });

    test('境界値 00:00 と 23:59 をパースできる', () {
      expect(HourMinute.tryParse('00:00')!.totalMinutes, 0);
      expect(HourMinute.tryParse('23:59')!.totalMinutes, 23 * 60 + 59);
    });

    test('範囲外の時・分は null', () {
      expect(HourMinute.tryParse('24:00'), isNull);
      expect(HourMinute.tryParse('17:60'), isNull);
      expect(HourMinute.tryParse('-1:30'), isNull);
    });

    test('形式が不正な文字列は null', () {
      expect(HourMinute.tryParse(''), isNull);
      expect(HourMinute.tryParse('1700'), isNull);
      expect(HourMinute.tryParse('17:00:00'), isNull);
      expect(HourMinute.tryParse('ab:cd'), isNull);
    });
  });

  group('HourMinute.fromDateTime', () {
    test('DateTime の時・分を取り出す', () {
      final time = HourMinute.fromDateTime(DateTime(2026, 7, 18, 9, 30));

      expect(time.hour, 9);
      expect(time.minute, 30);
    });
  });

  group('HourMinute.totalMinutes', () {
    test('0 時からの経過分を返す', () {
      expect(const HourMinute(hour: 17, minute: 30).totalMinutes, 1050);
    });
  });

  group('HourMinute.format', () {
    test('ゼロ埋めした HH:mm 文字列を返す', () {
      expect(const HourMinute(hour: 8, minute: 5).format(), '08:05');
      expect(const HourMinute(hour: 21, minute: 0).format(), '21:00');
    });
  });
}

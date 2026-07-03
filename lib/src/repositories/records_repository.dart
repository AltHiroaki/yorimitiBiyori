import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/suggestion_record.dart';

/// shared_preferences の保存キー（仕様書 5.4）。
const String recordsPreferenceKey = 'yorimiti_biyori_records';

/// 実施・スキップ履歴を shared_preferences に JSON 文字列で保存・復元する repository。
class RecordsRepository {
  /// 保存済みの履歴を全件読み込む。
  /// 未保存・JSON 破損時は空リストに安全フォールバックする。
  /// 1件単位で壊れたレコードはスキップし、残りは維持する。
  Future<List<SuggestionRecord>> loadRecords() async {
    final preferences = await SharedPreferences.getInstance();
    final source = preferences.getString(recordsPreferenceKey);
    if (source == null) {
      return [];
    }

    try {
      final decodedJson = jsonDecode(source);
      if (decodedJson is! List) {
        return [];
      }
      return _parseRecords(decodedJson);
    } on FormatException {
      return [];
    }
  }

  /// 履歴を1件追加して保存する。
  Future<void> addRecord(SuggestionRecord record) async {
    final records = await loadRecords();
    records.add(record);
    await _saveRecords(records);
  }

  /// 履歴を全件削除する（設定画面の履歴削除。取り消しできない）。
  Future<void> deleteAllRecords() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(recordsPreferenceKey);
  }

  Future<void> _saveRecords(List<SuggestionRecord> records) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedRecords =
        records.map((record) => record.toJson()).toList();
    await preferences.setString(
      recordsPreferenceKey,
      jsonEncode(encodedRecords),
    );
  }

  List<SuggestionRecord> _parseRecords(List<dynamic> decodedJson) {
    final records = <SuggestionRecord>[];
    for (final recordJson in decodedJson) {
      if (recordJson is! Map<String, dynamic>) {
        continue;
      }
      final record = SuggestionRecord.fromJson(recordJson);
      if (record != null) {
        records.add(record);
      }
    }
    return records;
  }
}

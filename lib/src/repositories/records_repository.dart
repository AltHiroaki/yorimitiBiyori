import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/suggestion_record.dart';

/// shared_preferences の保存キー（仕様書 5.4）。
const String recordsPreferenceKey = 'yorimichi_biyori_records';

/// shared_preferences に保存する履歴 JSON の現行スキーマバージョン。
const int recordsSchemaVersion = 1;

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

    return parseRecordsJsonSource(source);
  }

  /// 履歴を1件追加して保存する。
  Future<void> addRecord(SuggestionRecord record) async {
    final records = await loadRecords();
    records.add(record);
    await _saveRecords(records);
  }

  /// 指定 ID の履歴を1件削除する（該当なしなら何もしない）。
  /// スキップから復活したよりみちの完了時に、元のスキップ履歴を消すために使う。
  Future<void> deleteRecord(String recordId) async {
    final records = await loadRecords();
    final lengthBefore = records.length;
    records.removeWhere((record) => record.id == recordId);
    if (records.length == lengthBefore) {
      return;
    }
    await _saveRecords(records);
  }

  /// 履歴を全件削除する（設定画面の履歴削除。取り消しできない）。
  Future<void> deleteAllRecords() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(recordsPreferenceKey);
  }

  Future<void> _saveRecords(List<SuggestionRecord> records) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedRecords = records.map((record) => record.toJson()).toList();
    final encodedStorage = {
      'version': recordsSchemaVersion,
      'records': encodedRecords,
    };
    await preferences.setString(
      recordsPreferenceKey,
      jsonEncode(encodedStorage),
    );
  }

  static List<SuggestionRecord> _parseRecords(List<dynamic> decodedRecords) {
    final records = <SuggestionRecord>[];
    for (final recordJson in decodedRecords) {
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

/// 保存文字列から履歴を復元する入口。
/// 将来スキーマが変わったときは、ここで version を見て移行処理を挟む。
List<SuggestionRecord> parseRecordsJsonSource(String source) {
  try {
    return parseRecordsJson(jsonDecode(source));
  } on FormatException {
    return [];
  }
}

List<SuggestionRecord> parseRecordsJson(Object? decodedJson) {
  if (decodedJson is List) {
    return RecordsRepository._parseRecords(decodedJson);
  }

  if (decodedJson is! Map<String, dynamic>) {
    return [];
  }

  if (decodedJson['version'] != recordsSchemaVersion) {
    return [];
  }

  final decodedRecords = decodedJson['records'];
  if (decodedRecords is! List) {
    return [];
  }
  return RecordsRepository._parseRecords(decodedRecords);
}

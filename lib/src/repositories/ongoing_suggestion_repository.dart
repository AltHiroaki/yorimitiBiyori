import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ongoing_suggestion.dart';

/// shared_preferences に保存する実施中よりみちのキー。
const String ongoingSuggestionPreferenceKey =
    'yorimiti_biyori_ongoing_suggestion';

/// 実施中よりみち JSON の現行スキーマバージョン。
const int ongoingSuggestionSchemaVersion = 1;

/// 実施中のよりみち（提案 ID＋開始時刻）を保存・復元する repository。
/// タブ切替・アプリ再起動をまたいで実施中状態を維持するために使う（issue #48）。
class OngoingSuggestionRepository {
  /// 保存済みの実施中よりみちを読み込む。
  ///
  /// 未保存・JSON 破損・不正な形の場合は null（実施中なし）にフォールバックする。
  Future<OngoingSuggestion?> loadOngoingSuggestion() async {
    final preferences = await SharedPreferences.getInstance();
    final source = preferences.getString(ongoingSuggestionPreferenceKey);
    if (source == null) {
      return null;
    }

    return parseOngoingSuggestionJsonSource(source);
  }

  /// 実施中のよりみちを保存する。既存の実施中は上書きされる。
  Future<void> saveOngoingSuggestion(OngoingSuggestion ongoing) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      ongoingSuggestionPreferenceKey,
      jsonEncode({
        'version': ongoingSuggestionSchemaVersion,
        ...ongoing.toJson(),
      }),
    );
  }

  /// 完了・スキップ時に実施中状態を解除する。
  Future<void> clearOngoingSuggestion() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(ongoingSuggestionPreferenceKey);
  }
}

/// 保存文字列から実施中よりみちを復元する入口。
OngoingSuggestion? parseOngoingSuggestionJsonSource(String source) {
  try {
    return parseOngoingSuggestionJson(jsonDecode(source));
  } on FormatException {
    return null;
  }
}

OngoingSuggestion? parseOngoingSuggestionJson(Object? decodedJson) {
  if (decodedJson is! Map<String, dynamic>) {
    return null;
  }

  final version = decodedJson['version'];
  if (version != ongoingSuggestionSchemaVersion) {
    return null;
  }

  return OngoingSuggestion.fromJson(decodedJson);
}

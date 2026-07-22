import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences に保存する表示中提案 ID のキー。
const String currentSuggestionPreferenceKey =
    'yorimichi_biyori_current_suggestion';

/// 表示中提案 JSON の現行スキーマバージョン。
const int currentSuggestionSchemaVersion = 1;

/// 提案タブで現在表示している提案 ID を保存・復元する repository。
class CurrentSuggestionRepository {
  /// 保存済みの表示中提案 ID を読み込む。
  ///
  /// 未保存・JSON 破損・不正な形の場合は null にフォールバックする。
  Future<String?> loadCurrentSuggestionId() async {
    final preferences = await SharedPreferences.getInstance();
    final source = preferences.getString(currentSuggestionPreferenceKey);
    if (source == null) {
      return null;
    }

    return parseCurrentSuggestionJsonSource(source);
  }

  /// 表示中の提案 ID を保存する。
  Future<void> saveCurrentSuggestionId(String suggestionId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      currentSuggestionPreferenceKey,
      jsonEncode({
        'version': currentSuggestionSchemaVersion,
        'suggestion_id': suggestionId,
      }),
    );
  }

  /// 表示できる提案がない場合などに、保存済みの表示中 ID を削除する。
  Future<void> clearCurrentSuggestion() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(currentSuggestionPreferenceKey);
  }
}

/// 保存文字列から表示中提案 ID を復元する入口。
String? parseCurrentSuggestionJsonSource(String source) {
  try {
    return parseCurrentSuggestionJson(jsonDecode(source));
  } on FormatException {
    return null;
  }
}

String? parseCurrentSuggestionJson(Object? decodedJson) {
  if (decodedJson is! Map<String, dynamic>) {
    return null;
  }

  final version = decodedJson['version'];
  if (version != currentSuggestionSchemaVersion) {
    return null;
  }

  final suggestionId = decodedJson['suggestion_id'];
  if (suggestionId is! String || suggestionId.isEmpty) {
    return null;
  }
  return suggestionId;
}

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/suggestion.dart';

const String suggestionsAssetPath = 'assets/data/suggestions.json';

/// 提案候補データをアプリ同梱 JSON から読み込む repository。
class SuggestionRepository {
  SuggestionRepository({
    AssetBundle? assetBundle,
    this.assetPath = suggestionsAssetPath,
  }) : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  final String assetPath;

  Future<List<Suggestion>> loadSuggestions() async {
    // AssetBundle.loadString はデータが50KBを超えると UTF-8 デコードを
    // 別 isolate（compute）に逃がす。件数が増えて閾値を超えると、ウィジェット
    // テストの pump（実イベントループを回さない）内では isolate からの応答を
    // 待てず固まってしまうため、ここでは常にメインisolateでデコードする。
    final data = await _assetBundle.load(assetPath);
    final source = utf8.decode(Uint8List.sublistView(data));
    return parseSuggestionsJson(source);
  }
}

/// JSON 全体が壊れている場合は FormatException を投げる。
/// 1件単位の不正データは Suggestion.fromJson の結果に従ってスキップする。
List<Suggestion> parseSuggestionsJson(String source) {
  final decodedJson = jsonDecode(source);
  if (decodedJson is! List<dynamic>) {
    throw const FormatException('suggestions.json must be a JSON array.');
  }

  final suggestions = <Suggestion>[];
  for (final decodedSuggestion in decodedJson) {
    if (decodedSuggestion is! Map) {
      continue;
    }

    final suggestion = Suggestion.fromJson(
      Map<String, dynamic>.from(decodedSuggestion),
    );
    if (suggestion != null) {
      suggestions.add(suggestion);
    }
  }
  return suggestions;
}

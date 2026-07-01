import 'package:flutter_test/flutter_test.dart';

import 'package:yorimiti_biyori/src/models/suggestion.dart';

void main() {
  final validJson = {
    'id': 'music_jazz_focus',
    'title': '作業用にジャズを1曲だけ流す',
    'description': '歌詞のないジャズを1曲、作業や勉強のBGMにしてみる。',
    'detail': '配信サービスの「作業用ジャズ」プレイリストから1曲選ぶだけでOK。',
    'category': 'music',
    'tags': ['ジャズ', '作業向け', '無料'],
    'budget_yen': 0,
    'where_to_try': '音楽配信アプリで「作業用 ジャズ」と検索してプレイリストを開く。',
    'estimated_minutes': 5,
    'weight': 1.2,
  };

  test('fromJson/toJson が往復する', () {
    final suggestion = Suggestion.fromJson(validJson);

    expect(suggestion, isNotNull);
    expect(suggestion!.toJson(), validJson);
  });

  test('必須フィールドが欠けている場合は null を返す（例外を投げない）', () {
    final brokenJson = Map<String, dynamic>.from(validJson)..remove('title');

    expect(Suggestion.fromJson(brokenJson), isNull);
  });

  test('フィールドの型が不正な場合も null を返す（例外を投げない）', () {
    final brokenJson = Map<String, dynamic>.from(validJson)
      ..['tags'] = 'ジャズ';

    expect(Suggestion.fromJson(brokenJson), isNull);
  });
}

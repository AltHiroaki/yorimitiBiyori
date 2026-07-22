import 'package:flutter_test/flutter_test.dart';

import 'package:yorimichi_biyori/src/models/suggestion.dart';

void main() {
  final validJson = {
    'id': 'music_jazz_focus',
    'title': '作業用にジャズを1曲だけ流す',
    'description': '歌詞のないジャズを1曲、作業や勉強のBGMにしてみる。',
    'category': 'music',
    'tags': ['ジャズ', '作業向け', '無料'],
    'estimated_minutes': 5,
    'weight': 1.2,
  };

  final validCookJson = {
    'id': 'cook_high_protein_bowl',
    'title': '高タンパク丼を作る',
    'description': '卵や鶏むね肉を使って、手早く食べられる高タンパク丼を作る。',
    'recipe': '材料：\nご飯1膳、鶏むね肉100g\n\n手順：\n1. 鶏肉を焼く。\n2. ご飯にのせる。',
    'category': 'cook',
    'tags': ['高タンパク', '丼', '和食'],
    'estimated_minutes': 20,
    'weight': 1.1,
  };

  test('fromJson/toJson が往復する（recipe なし）', () {
    final suggestion = Suggestion.fromJson(validJson);

    expect(suggestion, isNotNull);
    expect(suggestion!.recipe, isNull);
    expect(suggestion.toJson(), validJson);
  });

  test('fromJson/toJson が往復する（料理は recipe を持つ）', () {
    final suggestion = Suggestion.fromJson(validCookJson);

    expect(suggestion, isNotNull);
    expect(suggestion!.recipe, validCookJson['recipe']);
    expect(suggestion.toJson(), validCookJson);
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

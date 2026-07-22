import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimichi_biyori/src/features/recommendation/suggestion_picker.dart';
import 'package:yorimichi_biyori/src/models/interest_category.dart';
import 'package:yorimichi_biyori/src/repositories/suggestion_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parseSuggestionsJson は正常な提案だけを読み込む', () {
    const source = '''
[
  {
    "id": "music_jazz_focus",
    "title": "作業用にジャズを1曲だけ流す",
    "description": "歌詞のないジャズを1曲だけ流す。",
    "category": "music",
    "tags": ["ジャズ", "作業向け", "無料"],
    "estimated_minutes": 5,
    "weight": 1.2
  },
  {
    "id": "broken"
  }
]
''';

    final suggestions = parseSuggestionsJson(source);

    expect(suggestions, hasLength(1));
    expect(suggestions.single.id, 'music_jazz_focus');
  });

  test('parseSuggestionsJson は配列以外の JSON で FormatException を投げる', () {
    expect(
      () => parseSuggestionsJson('{"id": "music_jazz_focus"}'),
      throwsFormatException,
    );
  });

  test('assets/data/suggestions.json は新スキーマの提案として読み込める', () async {
    final source = await rootBundle.loadString(suggestionsAssetPath);

    final suggestions = parseSuggestionsJson(source);
    final knownCategoryIds = [
      ...InterestCategories.all,
      ...InterestCategories.developmentCategories,
    ].map((category) => category.id).toSet();
    final suggestionIds = suggestions
        .map((suggestion) => suggestion.id)
        .toList();

    expect(suggestions, isNotEmpty);
    expect(suggestionIds.toSet(), hasLength(suggestionIds.length));
    expect(
      suggestions.map((suggestion) => suggestion.category).toSet(),
      containsAll(['music', 'cook', 'read', 'movie', 'walk']),
    );
    expect(
      suggestions.every((suggestion) {
        return knownCategoryIds.contains(suggestion.category);
      }),
      isTrue,
    );
    expect(
      suggestions.every((suggestion) {
        return suggestion.title.isNotEmpty &&
            suggestion.description.isNotEmpty &&
            suggestion.tags.isNotEmpty;
      }),
      isTrue,
    );
    expect(
      suggestions.every((suggestion) => suggestion.estimatedMinutes > 0),
      isTrue,
    );
    // recipe は料理カテゴリだけが持つ。
    expect(
      suggestions.every((suggestion) {
        return suggestion.category == 'cook'
            ? suggestion.recipe != null && suggestion.recipe!.isNotEmpty
            : suggestion.recipe == null;
      }),
      isTrue,
    );
  });

  test('MVP 全カテゴリの全詳細設定選択肢に、タグが一致する提案が1件以上ある', () async {
    final source = await rootBundle.loadString(suggestionsAssetPath);
    final suggestions = parseSuggestionsJson(source);

    for (final category in InterestCategories.all) {
      for (final group in category.detailSettingGroups) {
        for (final option in group.options) {
          if (option == noPreferenceOption) {
            continue;
          }
          final hasMatchingSuggestion = suggestions.any(
            (suggestion) =>
                suggestion.category == category.id &&
                suggestion.tags.contains(option),
          );
          expect(
            hasMatchingSuggestion,
            isTrue,
            reason:
                '${category.label}（${category.id}）の選択肢「$option」'
                'に一致する提案が suggestions.json にない。'
                '該当タグを持つ提案を追加するか、選択肢を見直すこと。',
          );
        }
      }
    }
  });

  test('料理データのrecipeは材料と2〜4手順が改行区切りのレシピ形式になっている', () async {
    final source = await rootBundle.loadString(suggestionsAssetPath);
    final suggestions = parseSuggestionsJson(source);
    final cookingSuggestions = suggestions.where(
      (suggestion) => suggestion.category == 'cook',
    );

    expect(cookingSuggestions, isNotEmpty);
    for (final suggestion in cookingSuggestions) {
      final recipe = suggestion.recipe!;
      expect(
        recipe,
        startsWith('材料：\n'),
        reason: '${suggestion.id} のrecipeは「材料：」と改行で始める。',
      );
      expect(
        recipe,
        contains('\n\n手順：\n1. '),
        reason: '${suggestion.id} のrecipeは空行を挟んで「手順：」を分け、手順1を改行する。',
      );
      expect(
        recipe,
        contains('\n2. '),
        reason: '${suggestion.id} のrecipeは2手順以上を番号ごとに改行する。',
      );
      expect(
        recipe,
        isNot(contains('\n5. ')),
        reason: '${suggestion.id} のrecipeは4手順以内にする。',
      );
    }
  });

  test('料理データは各ジャンルに50件以上あり、タイトルが重複していない', () async {
    final source = await rootBundle.loadString(suggestionsAssetPath);
    final suggestions = parseSuggestionsJson(source);
    final cookingSuggestions = suggestions
        .where((suggestion) => suggestion.category == 'cook')
        .toList();
    final cookingCategory = InterestCategories.all.singleWhere(
      (category) => category.id == 'cook',
    );
    final genreGroup = cookingCategory.detailSettingGroups.singleWhere(
      (group) => group.id == 'genre',
    );

    for (final genre in genreGroup.options) {
      final matchingCount = cookingSuggestions.where((suggestion) {
        return suggestion.tags.contains(genre);
      }).length;
      expect(
        matchingCount,
        greaterThanOrEqualTo(50),
        reason: '料理ジャンル「$genre」の提案は50件以上必要。',
      );
    }

    final cookingTitles = cookingSuggestions
        .map((suggestion) => suggestion.title)
        .toSet();
    expect(
      cookingTitles,
      hasLength(cookingSuggestions.length),
      reason: '料理の提案タイトルは重複させない。',
    );
  });

  test('すべての料理データに有効な調理法タグがある', () async {
    final source = await rootBundle.loadString(suggestionsAssetPath);
    final suggestions = parseSuggestionsJson(source);
    final cookingCategory = InterestCategories.all.singleWhere(
      (category) => category.id == 'cook',
    );
    final cookingMethodGroup = cookingCategory.detailSettingGroups.singleWhere(
      (group) => group.id == 'cooking_method',
    );

    for (final suggestion in suggestions.where(
      (suggestion) => suggestion.category == 'cook',
    )) {
      final hasCookingMethod = cookingMethodGroup.options.any(
        suggestion.tags.contains,
      );
      expect(
        hasCookingMethod,
        isTrue,
        reason: '${suggestion.id} に有効な調理法タグがない。',
      );
    }
  });
}

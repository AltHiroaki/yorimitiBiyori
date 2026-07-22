import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimichi_biyori/src/features/recommendation/suggestion_picker.dart';
import 'package:yorimichi_biyori/src/models/interest_category.dart';
import 'package:yorimichi_biyori/src/models/suggestion.dart';
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

  test('カテゴリ別JSONはファイル名とcategoryが一致し、全件を結合して読み込める', () async {
    expect(
      suggestionAssetPathsByCategory.keys,
      orderedEquals(['music', 'cook', 'read', 'movie', 'walk']),
    );

    final suggestionsByFile = <Suggestion>[];
    for (final entry in suggestionAssetPathsByCategory.entries) {
      final source = await _loadAssetSource(entry.value);
      final decodedJson = jsonDecode(source);
      expect(
        decodedJson,
        isA<List<dynamic>>(),
        reason: '${entry.value} はJSON配列にする。',
      );

      final decodedSuggestions = decodedJson as List<dynamic>;
      final suggestions = parseSuggestionsJson(source, sourceName: entry.value);
      expect(
        suggestions,
        hasLength(decodedSuggestions.length),
        reason: '${entry.value} に必須フィールド欠け・型不一致のデータがある。',
      );
      expect(
        suggestions.every((suggestion) => suggestion.category == entry.key),
        isTrue,
        reason: '${entry.value} にはcategory=${entry.key}のデータだけを置く。',
      );
      suggestionsByFile.addAll(suggestions);
    }

    final suggestions = await SuggestionRepository().loadSuggestions();
    final knownCategoryIds = [
      ...InterestCategories.all,
      ...InterestCategories.developmentCategories,
    ].map((category) => category.id).toSet();
    final suggestionIds = suggestions
        .map((suggestion) => suggestion.id)
        .toList();

    expect(suggestions, isNotEmpty);
    expect(suggestions, hasLength(suggestionsByFile.length));
    expect(
      suggestions.map((suggestion) => suggestion.id).toSet(),
      suggestionsByFile.map((suggestion) => suggestion.id).toSet(),
    );
    expect(suggestionIds.toSet(), hasLength(suggestionIds.length));
    expect(
      suggestions.map((suggestion) => suggestion.title).toSet(),
      hasLength(suggestions.length),
    );
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
      suggestions.every(
        (suggestion) =>
            suggestion.estimatedMinutes > 0 && suggestion.weight > 0,
      ),
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

  test('各提案のtagsは所属カテゴリの全詳細設定グループと矛盾しない', () async {
    final suggestions = await SuggestionRepository().loadSuggestions();
    final categories = [
      ...InterestCategories.all,
      ...InterestCategories.developmentCategories,
    ];
    final optionsByCategory = {
      for (final category in categories)
        category.id: category.detailSettingGroups
            .expand((group) => group.options)
            .toSet(),
    };
    final allDefinedOptions = optionsByCategory.values
        .expand((options) => options)
        .toSet();

    for (final suggestion in suggestions) {
      final category = categories.singleWhere(
        (category) => category.id == suggestion.category,
      );
      for (final group in category.detailSettingGroups) {
        expect(
          suggestion.tags.any(group.options.contains),
          isTrue,
          reason:
              '${suggestion.id} に${category.label}の'
              '「${group.label}」タグがない。',
        );
      }

      final categoryOptions = optionsByCategory[suggestion.category]!;
      final conflictingTags = suggestion.tags.where(
        (tag) =>
            allDefinedOptions.contains(tag) && !categoryOptions.contains(tag),
      );
      expect(
        conflictingTags,
        isEmpty,
        reason: '${suggestion.id} に他カテゴリの詳細設定タグが含まれている。',
      );
    }
  });

  test('MVP 全カテゴリの全詳細設定選択肢に、タグが一致する提案が50件以上ある', () async {
    final suggestions = await SuggestionRepository().loadSuggestions();

    for (final category in InterestCategories.all) {
      for (final group in category.detailSettingGroups) {
        for (final option in group.options) {
          if (option == noPreferenceOption) {
            continue;
          }
          final matchingCount = suggestions
              .where(
                (suggestion) =>
                    suggestion.category == category.id &&
                    suggestion.tags.contains(option),
              )
              .length;
          expect(
            matchingCount,
            greaterThanOrEqualTo(50),
            reason:
                '${category.label}（${category.id}）の選択肢「$option」'
                'に一致する提案は50件以上必要。',
          );
        }
      }
    }
  });

  test('料理データのrecipeは材料と2〜4手順が改行区切りのレシピ形式になっている', () async {
    final suggestions = await SuggestionRepository().loadSuggestions();
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
    final suggestions = await SuggestionRepository().loadSuggestions();
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

  test('読書データは各ジャンルに50件以上あり、タイトルが重複していない', () async {
    final suggestions = await SuggestionRepository().loadSuggestions();
    final readingSuggestions = suggestions
        .where((suggestion) => suggestion.category == 'read')
        .toList();
    final readingCategory = InterestCategories.all.singleWhere(
      (category) => category.id == 'read',
    );
    final genreGroup = readingCategory.detailSettingGroups.singleWhere(
      (group) => group.id == 'genre',
    );

    for (final genre in genreGroup.options) {
      final matchingCount = readingSuggestions.where((suggestion) {
        return suggestion.tags.contains(genre);
      }).length;
      expect(
        matchingCount,
        greaterThanOrEqualTo(50),
        reason: '読書ジャンル「$genre」の提案は50件以上必要。',
      );
    }

    final readingTitles = readingSuggestions
        .map((suggestion) => suggestion.title)
        .toSet();
    expect(
      readingTitles,
      hasLength(readingSuggestions.length),
      reason: '読書の提案タイトルは重複させない。',
    );
  });

  test('すべての料理データに有効な調理法タグがある', () async {
    final suggestions = await SuggestionRepository().loadSuggestions();
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

Future<String> _loadAssetSource(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  return utf8.decode(Uint8List.sublistView(data));
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimiti_biyori/src/features/recommendation/suggestion_picker.dart';
import 'package:yorimiti_biyori/src/models/interest_category.dart';
import 'package:yorimiti_biyori/src/repositories/suggestion_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parseSuggestionsJson は正常な提案だけを読み込む', () {
    const source = '''
[
  {
    "id": "music_jazz_focus",
    "title": "作業用にジャズを1曲だけ流す",
    "description": "歌詞のないジャズを1曲だけ流す。",
    "detail": "作業用ジャズのプレイリストから1曲選ぶ。",
    "category": "music",
    "tags": ["ジャズ", "作業向け", "無料"],
    "budget_yen": 0,
    "where_to_try": "音楽配信アプリで検索する。",
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
    final suggestionIds =
        suggestions.map((suggestion) => suggestion.id).toList();

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
            suggestion.detail.isNotEmpty &&
            suggestion.whereToTry.isNotEmpty &&
            suggestion.tags.isNotEmpty;
      }),
      isTrue,
    );
    expect(
      suggestions.every((suggestion) => suggestion.budgetYen >= 0),
      isTrue,
    );
    expect(
      suggestions.every((suggestion) => suggestion.estimatedMinutes > 0),
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
            reason: '${category.label}（${category.id}）の選択肢「$option」'
                'に一致する提案が suggestions.json にない。'
                '該当タグを持つ提案を追加するか、選択肢を見直すこと。',
          );
        }
      }
    }
  });
}

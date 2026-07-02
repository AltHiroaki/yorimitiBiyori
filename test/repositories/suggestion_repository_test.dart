import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
    "difficulty": "やさしい",
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

    expect(suggestions, isNotEmpty);
    expect(
      suggestions.map((suggestion) => suggestion.category).toSet(),
      containsAll(['music', 'cook', 'read', 'movie', 'walk']),
    );
    expect(
      suggestions.every((suggestion) => suggestion.estimatedMinutes > 0),
      isTrue,
    );
  });
}

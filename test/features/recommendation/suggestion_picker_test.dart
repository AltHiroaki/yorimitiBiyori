import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yorimiti_biyori/src/features/recommendation/suggestion_picker.dart';
import 'package:yorimiti_biyori/src/models/suggestion.dart';
import 'package:yorimiti_biyori/src/models/user_settings.dart';

void main() {
  group('filterSuggestions', () {
    test('選択カテゴリに一致する提案だけを返す', () {
      final suggestions = [
        _suggestion(id: 'music', category: 'music'),
        _suggestion(id: 'walk', category: 'walk'),
      ];
      const settings = UserSettings(selectedCategories: ['music']);

      final filteredSuggestions = filterSuggestions(suggestions, settings);

      expect(filteredSuggestions.map((suggestion) => suggestion.id), ['music']);
    });

    test('詳細設定はグループ内 OR・グループ間 AND で判定する', () {
      final suggestions = [
        _suggestion(
          id: 'matched',
          category: 'music',
          tags: ['ジャズ', '作業向け', '無料'],
        ),
        _suggestion(
          id: 'wrong_genre',
          category: 'music',
          tags: ['ポップス', '作業向け', '無料'],
        ),
        _suggestion(
          id: 'wrong_mood',
          category: 'music',
          tags: ['ジャズ', 'リラックス', '無料'],
        ),
      ];
      const settings = UserSettings(
        selectedCategories: ['music'],
        detailSettings: {
          'music': {
            'genre': ['ジャズ', 'クラシック'],
            'mood': ['作業向け'],
          },
        },
      );

      final filteredSuggestions = filterSuggestions(suggestions, settings);

      expect(filteredSuggestions.map((suggestion) => suggestion.id), [
        'matched',
      ]);
    });

    test('料理はジャンル×調理法の2グループをAND条件で絞り込む', () {
      final suggestions = [
        _suggestion(
          id: 'matched',
          category: 'cook',
          tags: ['和食', '焼く'],
        ),
        _suggestion(
          id: 'wrong_genre',
          category: 'cook',
          tags: ['洋食', '焼く'],
        ),
        _suggestion(
          id: 'wrong_method',
          category: 'cook',
          tags: ['和食', '煮る'],
        ),
      ];
      const settings = UserSettings(
        selectedCategories: ['cook'],
        detailSettings: {
          'cook': {
            'genre': ['和食'],
            'cooking_method': ['焼く'],
          },
        },
      );

      final filteredSuggestions = filterSuggestions(suggestions, settings);

      expect(filteredSuggestions.map((suggestion) => suggestion.id), [
        'matched',
      ]);
    });

    test('未選択グループと問わないは絞り込まない', () {
      final suggestions = [
        _suggestion(id: 'free', category: 'movie', tags: ['コメディ', 'Netflix']),
        _suggestion(
          id: 'prime',
          category: 'movie',
          tags: ['ドラマ', 'Amazon Prime'],
        ),
      ];
      const settings = UserSettings(
        selectedCategories: ['movie'],
        detailSettings: {
          'movie': {
            'genre': [],
            'time': ['問わない'],
          },
        },
      );

      final filteredSuggestions = filterSuggestions(suggestions, settings);

      expect(filteredSuggestions, hasLength(2));
    });

    test('複数カテゴリ選択時はカテゴリごとの詳細設定を OR で扱う', () {
      final suggestions = [
        _suggestion(
          id: 'music_match',
          category: 'music',
          tags: ['ジャズ'],
        ),
        _suggestion(
          id: 'movie_match',
          category: 'movie',
          tags: ['コメディ'],
        ),
        _suggestion(
          id: 'music_wrong_detail',
          category: 'music',
          tags: ['ポップス'],
        ),
        _suggestion(
          id: 'cook_unselected',
          category: 'cook',
          tags: ['和食'],
        ),
      ];
      const settings = UserSettings(
        selectedCategories: ['music', 'movie'],
        detailSettings: {
          'music': {
            'genre': ['ジャズ'],
          },
          'movie': {
            'genre': ['コメディ'],
          },
        },
      );

      final filteredSuggestions = filterSuggestions(suggestions, settings);

      expect(filteredSuggestions.map((suggestion) => suggestion.id), [
        'music_match',
        'movie_match',
      ]);
    });

    test('音楽の追加ジャンルごとにタグが一致する提案だけを返す', () {
      const addedGenres = [
        'ロック',
        'ヒップホップ・R&B',
        'アニソン・ゲーム音楽',
        'EDM・テクノ',
      ];
      final suggestions = [
        for (final genre in addedGenres)
          _suggestion(id: genre, category: 'music', tags: [genre]),
        _suggestion(
          id: 'existing_genre',
          category: 'music',
          tags: ['ポップス'],
        ),
      ];

      for (final genre in addedGenres) {
        final filteredSuggestions = filterSuggestions(
          suggestions,
          UserSettings(
            selectedCategories: const ['music'],
            detailSettings: {
              'music': {
                'genre': [genre],
              },
            },
          ),
        );

        expect(
          filteredSuggestions.map((suggestion) => suggestion.id),
          [genre],
          reason: '$genre の選択時は同じタグの提案だけが残るはず',
        );
      }
    });
  });

  group('excludeRecent', () {
    test('直近3件を除外する', () {
      final suggestions = [
        _suggestion(id: 'a'),
        _suggestion(id: 'b'),
        _suggestion(id: 'c'),
        _suggestion(id: 'd'),
      ];

      final filteredSuggestions = excludeRecent(suggestions, ['a', 'b', 'c']);

      expect(filteredSuggestions.map((suggestion) => suggestion.id), ['d']);
    });

    test('候補が尽きたら直前1件のみ除外に緩和する', () {
      final suggestions = [
        _suggestion(id: 'a'),
        _suggestion(id: 'b'),
        _suggestion(id: 'c'),
      ];

      final filteredSuggestions = excludeRecent(suggestions, ['a', 'b', 'c']);

      expect(filteredSuggestions.map((suggestion) => suggestion.id), [
        'a',
        'b',
      ]);
    });
  });

  group('pickWeightedRandom', () {
    test('weight が 0 以下の候補は選ばない', () {
      final suggestions = [
        _suggestion(id: 'zero', weight: 0),
        _suggestion(id: 'positive', weight: 1),
      ];

      final selectedSuggestion = pickWeightedRandom(
        suggestions,
        _FixedRandom(0),
      );

      expect(selectedSuggestion?.id, 'positive');
    });

    test('weight の累積範囲に入った候補を返す', () {
      final suggestions = [
        _suggestion(id: 'small', weight: 1),
        _suggestion(id: 'large', weight: 3),
      ];

      final firstSelected = pickWeightedRandom(suggestions, _FixedRandom(0.2));
      final secondSelected = pickWeightedRandom(suggestions, _FixedRandom(0.5));

      expect(firstSelected?.id, 'small');
      expect(secondSelected?.id, 'large');
    });

    test('weight が正の候補がないときは null を返す', () {
      final suggestions = [
        _suggestion(id: 'zero', weight: 0),
        _suggestion(id: 'negative', weight: -1),
      ];

      final selectedSuggestion = pickWeightedRandom(
        suggestions,
        _FixedRandom(0),
      );

      expect(selectedSuggestion, isNull);
    });
  });
}

Suggestion _suggestion({
  required String id,
  String category = 'music',
  List<String> tags = const [],
  double weight = 1,
}) {
  return Suggestion(
    id: id,
    title: id,
    description: 'description',
    category: category,
    tags: tags,
    estimatedMinutes: 10,
    weight: weight,
  );
}

class _FixedRandom implements Random {
  const _FixedRandom(this.fixedDouble);

  final double fixedDouble;

  @override
  bool nextBool() => fixedDouble >= 0.5;

  @override
  double nextDouble() => fixedDouble;

  @override
  int nextInt(int max) => (fixedDouble * max).floor();
}

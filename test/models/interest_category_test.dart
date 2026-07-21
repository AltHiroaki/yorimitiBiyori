import 'package:flutter_test/flutter_test.dart';

import 'package:yorimiti_biyori/src/models/interest_category.dart';

void main() {
  test('MVP コアカテゴリは音楽・料理・読書・映画の4種類', () {
    final categoryIds = InterestCategories.all.map((category) => category.id);

    expect(categoryIds, ['music', 'cook', 'read', 'movie']);
  });

  test('散歩は発展カテゴリとして定義を残す', () {
    final developmentIds =
        InterestCategories.developmentCategories.map((category) => category.id);

    expect(developmentIds, ['walk']);
  });

  test('MVP の各カテゴリの詳細設定はジャンル1グループに絞る', () {
    for (final category in InterestCategories.all) {
      expect(category.detailSettingGroups, hasLength(1));
    }
  });

  test('findById で id からカテゴリを取得できる', () {
    final music = InterestCategories.findById('music');

    expect(music, isNotNull);
    expect(music!.label, '音楽');
    expect(music.emoji, '🎵');
  });

  test('findById は発展カテゴリの散歩も解決できる', () {
    final walk = InterestCategories.findById('walk');

    expect(walk, isNotNull);
    expect(walk!.label, '散歩');
  });

  test('findById は存在しない id で null を返す', () {
    expect(InterestCategories.findById('unknown'), isNull);
  });

  test('音楽カテゴリの MVP 詳細設定は8種類のジャンルのみ', () {
    final music = InterestCategories.findById('music')!;
    final genreGroup = music.detailSettingGroups.single;

    expect(genreGroup.id, 'genre');
    expect(genreGroup.options, [
      'ポップス',
      'ジャズ',
      'クラシック',
      '洋楽',
      'ロック',
      'ヒップホップ・R&B',
      'アニソン・ゲーム音楽',
      'EDM・テクノ',
    ]);
  });
}

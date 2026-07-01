import 'package:flutter_test/flutter_test.dart';

import 'package:yorimiti_biyori/src/models/interest_category.dart';

void main() {
  test('5カテゴリが定義されている', () {
    final categoryIds = InterestCategories.all.map((category) => category.id);

    expect(categoryIds, ['music', 'cook', 'read', 'movie', 'walk']);
  });

  test('各カテゴリに詳細設定グループが1つ以上ある', () {
    for (final category in InterestCategories.all) {
      expect(category.detailSettingGroups, isNotEmpty);
    }
  });

  test('findById で id からカテゴリを取得できる', () {
    final music = InterestCategories.findById('music');

    expect(music, isNotNull);
    expect(music!.label, '音楽');
    expect(music.emoji, '🎵');
  });

  test('findById は存在しない id で null を返す', () {
    expect(InterestCategories.findById('unknown'), isNull);
  });

  test('音楽カテゴリの詳細設定グループが仕様どおり', () {
    final music = InterestCategories.findById('music')!;
    final groupIds = music.detailSettingGroups.map((group) => group.id);

    expect(groupIds, ['mood', 'genre', 'cost']);
  });
}

/// カテゴリ内の1つの詳細設定グループ（例：音楽の「気分」）。
class DetailSettingGroup {
  const DetailSettingGroup({
    required this.id,
    required this.label,
    required this.options,
  });

  final String id;
  final String label;
  final List<String> options;
}

/// 興味カテゴリ1件（id・表示名・絵文字・詳細設定グループ一覧）。
class InterestCategory {
  const InterestCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.detailSettingGroups,
  });

  final String id;
  final String label;
  final String emoji;
  final List<DetailSettingGroup> detailSettingGroups;
}

/// MVP カテゴリとカテゴリ別詳細設定のマスター定義（仕様書 3.4 の表を正とする）。
///
/// 企画書 ver6 に合わせ、MVP のコアカテゴリは音楽・料理・読書・映画の4種類とし、
/// 各カテゴリの詳細設定は「ジャンル」1グループのみに絞る。
/// 言語・気分・栄養素・時間・予算・視聴先などの複数項目での絞り込みは発展機能とする。
///
/// カテゴリを増やす場合はこのリストに追加するだけでよい。
class InterestCategories {
  InterestCategories._();

  /// MVP のコアカテゴリ（提案設定・オンボーディングの選択肢はこれを正とする）。
  static const List<InterestCategory> all = [
    InterestCategory(
      id: 'music',
      label: '音楽',
      emoji: '🎵',
      detailSettingGroups: [
        DetailSettingGroup(
          id: 'genre',
          label: 'ジャンル',
          options: ['ポップス', 'ジャズ', 'クラシック', '洋楽'],
        ),
      ],
    ),
    InterestCategory(
      id: 'cook',
      label: '料理',
      emoji: '🍳',
      detailSettingGroups: [
        DetailSettingGroup(
          id: 'genre',
          label: '味覚・ジャンル',
          options: ['和食', '洋食', '中華', 'イタリアン', 'アジア風', '激辛', 'さっぱり', 'ガッツリ'],
        ),
      ],
    ),
    InterestCategory(
      id: 'read',
      label: '読書',
      emoji: '📖',
      detailSettingGroups: [
        DetailSettingGroup(
          id: 'genre',
          label: 'ジャンル',
          options: [
            'エッセイ',
            '小説',
            'ノンフィクション',
            '詩集',
            'ミステリー・サスペンス',
            'SF・ファンタジー',
            'ビジネス・自己啓発',
            '歴史・教養',
          ],
        ),
      ],
    ),
    InterestCategory(
      id: 'movie',
      label: '映画',
      emoji: '🎬',
      detailSettingGroups: [
        DetailSettingGroup(
          id: 'genre',
          label: 'ジャンル',
          options: [
            'アクション',
            'コメディ',
            'ドラマ',
            'SF',
            'サスペンス',
            'ファンタジー',
            '恋愛',
            'アニメ',
            'ミステリー',
          ],
        ),
      ],
    ),
  ];

  /// 発展で追加するカテゴリ例（企画書 ver6 では MVP コアに含めない）。
  ///
  /// 定義・提案データは残しておき、発展段階で `all` に移して有効化する。
  /// `findById` はここも探索するため、既存の散歩データの表示名解決は維持される。
  static const List<InterestCategory> developmentCategories = [
    InterestCategory(
      id: 'walk',
      label: '散歩',
      emoji: '🚶',
      detailSettingGroups: [
        DetailSettingGroup(
          id: 'purpose',
          label: '目的',
          options: ['気分転換', '運動', '発見'],
        ),
      ],
    ),
  ];

  /// MVP・発展を通して該当するカテゴリがなければ null を返す。
  static InterestCategory? findById(String id) {
    for (final category in [...all, ...developmentCategories]) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }
}

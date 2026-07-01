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

/// 5カテゴリとカテゴリ別詳細設定のマスター定義（仕様書 3.4 の表を正とする）。
///
/// カテゴリを増やす場合はこのリストに追加するだけでよい。
class InterestCategories {
  InterestCategories._();

  static const List<InterestCategory> all = [
    InterestCategory(
      id: 'music',
      label: '音楽',
      emoji: '🎵',
      detailSettingGroups: [
        DetailSettingGroup(
          id: 'mood',
          label: '気分',
          options: ['作業向け', 'リラックス', '盛り上がりたい'],
        ),
        DetailSettingGroup(
          id: 'genre',
          label: 'ジャンル',
          options: ['ポップス', 'ジャズ', 'クラシック', '洋楽'],
        ),
        DetailSettingGroup(
          id: 'cost',
          label: '費用',
          options: ['有料', '無料', '問わない'],
        ),
      ],
    ),
    InterestCategory(
      id: 'cook',
      label: '料理',
      emoji: '🍳',
      detailSettingGroups: [
        DetailSettingGroup(
          id: 'nutrition',
          label: '栄養・ダイエット',
          options: ['高タンパク', '低糖質', '野菜多め', 'カロリーオフ'],
        ),
        DetailSettingGroup(
          id: 'genre',
          label: 'ジャンル',
          options: ['和食', '洋食', '中華', 'イタリアン', 'アジアン', '丼', '作り置き', 'ガッツリ'],
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
          options: ['エッセイ', '小説', 'ノンフィクション', '詩集'],
        ),
        DetailSettingGroup(
          id: 'time',
          label: '読書時間',
          options: ['10分以内', '30分', 'じっくり'],
        ),
        DetailSettingGroup(
          id: 'budget',
          label: '入手・予算',
          options: ['図書館', '電子書籍', '〜500円', '〜1000円'],
        ),
      ],
    ),
    InterestCategory(
      id: 'movie',
      label: '映画',
      emoji: '🎬',
      detailSettingGroups: [
        DetailSettingGroup(
          id: 'mood',
          label: '気分',
          options: ['泣ける', '笑える', '考えさせる'],
        ),
        DetailSettingGroup(
          id: 'time',
          label: '上映時間',
          options: ['90分以内', '問わない'],
        ),
        DetailSettingGroup(
          id: 'source',
          label: '視聴先',
          options: ['Netflix', 'Amazon Prime', '問わない'],
        ),
      ],
    ),
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
        DetailSettingGroup(
          id: 'time',
          label: '時間',
          options: ['15分以内', '30分', 'たっぷり'],
        ),
      ],
    ),
  ];

  /// 該当するカテゴリがなければ null を返す。
  static InterestCategory? findById(String id) {
    for (final category in all) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }
}

import 'package:flutter/material.dart';

import 'neumorphic_surface.dart';

/// 予算表示のラベル（0 円は「無料」）。
String formatBudgetLabel(int budgetYen) {
  return budgetYen == 0 ? '無料' : '¥$budgetYen';
}

/// 提案カードの共通レイアウト：
/// ヘッダー → タイトル → 説明 → タグ → 入手先 → 予算 → 補足行 の並び。
/// 提案タブのカード・完了演出の飛行カード・復活ダイアログで共用し、
/// 表示しない要素は null で省く（箇所ごとの差分はパラメータで吸収する）。
///
/// 操作ボタン列や外枠（NeumorphicSurface / Card / Dialog）は
/// 利用側がそれぞれ持つ。
class SuggestionCardContent extends StatelessWidget {
  const SuggestionCardContent({
    super.key,
    required this.title,
    this.headerIcon,
    this.headerLabel,
    this.titleMaxLines = 2,
    this.description,
    this.detail,
    this.tags,
    this.estimatedMinutes,
    this.whereToTry,
    this.budgetYen,
    this.footnote,
    this.titleSpacing = 8,
    this.sectionSpacing = 12,
  });

  /// ヘッダー行のアイコン（null なら文字ラベルのみ）。
  final IconData? headerIcon;

  /// ヘッダー行のラベル（例：今日のよりみち）。null ならヘッダーなし。
  final String? headerLabel;

  final String title;

  /// タイトルの最大行数。null なら折り返しを制限しない
  /// （スクロールできるダイアログ表示向け）。
  final int? titleMaxLines;

  final String? description;

  /// 始め方やコツなどの詳細説明。空・空白のみなら詳細ボタンを表示しない。
  final String? detail;

  /// タグ Chip の一覧。null ならタグ行なし。
  final List<String>? tags;

  /// タグ行の末尾に「約N分」Chip として表示する。null なら表示しない。
  final int? estimatedMinutes;

  final String? whereToTry;

  /// 予算。null なら予算行なし（0 は「無料」表示）。
  final int? budgetYen;

  /// 予算の位置に表示する補足行（例：実施中カードの「開始：HH:mm」）。
  final Widget? footnote;

  /// ヘッダー・タイトル・説明の間の余白。
  /// 復活ダイアログは既存の見た目を保つためやや広い値を使う。
  final double titleSpacing;

  /// 説明・タグ・入手先セクション間の余白。
  final double sectionSpacing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedDetail = detail?.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerLabel case final String headerLabel) ...[
          Row(
            children: [
              if (headerIcon case final IconData headerIcon) ...[
                Icon(headerIcon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  headerLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: titleSpacing),
        ],
        Text(
          title,
          maxLines: titleMaxLines,
          overflow: titleMaxLines == null ? null : TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (description case final String description) ...[
          SizedBox(height: titleSpacing),
          Text(description),
        ],
        if (normalizedDetail != null && normalizedDetail.isNotEmpty) ...[
          SizedBox(height: sectionSpacing),
          _SuggestionDetailSection(detail: normalizedDetail),
        ],
        if (tags case final List<String> tags) ...[
          SizedBox(height: sectionSpacing),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                NeumorphicChipFrame(child: Chip(label: Text(tag))),
              if (estimatedMinutes case final int estimatedMinutes)
                NeumorphicChipFrame(
                  child: Chip(label: Text('約$estimatedMinutes分')),
                ),
            ],
          ),
        ],
        if (whereToTry case final String whereToTry) ...[
          SizedBox(height: sectionSpacing),
          Text('入手先：$whereToTry'),
        ],
        if (budgetYen case final int budgetYen) ...[
          const SizedBox(height: 4),
          Text('予算：${formatBudgetLabel(budgetYen)}'),
        ],
        if (footnote case final Widget footnote) ...[
          const SizedBox(height: 4),
          footnote,
        ],
      ],
    );
  }
}

class _SuggestionDetailSection extends StatefulWidget {
  const _SuggestionDetailSection({required this.detail});

  final String detail;

  @override
  State<_SuggestionDetailSection> createState() =>
      _SuggestionDetailSectionState();
}

class _SuggestionDetailSectionState extends State<_SuggestionDetailSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          key: const ValueKey<String>('suggestion-detail-toggle'),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          label: Text(_isExpanded ? '詳しい内容を閉じる' : '詳しく見る'),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 4),
          Text(
            '詳しい内容',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.detail,
            key: const ValueKey<String>('suggestion-detail-content'),
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

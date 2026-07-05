import 'package:flutter/material.dart';

import '../repositories/records_repository.dart';
import '../widgets/section_card.dart';

/// 設定タブ。
/// UI プロトタイプの「03 設定」に対応する。
/// 履歴削除以外の項目は骨格のみで、各項目の編集・保存は今後の Phase で実装する。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.recordsRepository});

  /// テスト用に差し替え可能。null なら通常の repository を使う。
  final RecordsRepository? recordsRepository;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final RecordsRepository _recordsRepository;

  /// 履歴削除のインライン確認を表示中かどうか（仕様書 3.3）。
  bool _showDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    _recordsRepository = widget.recordsRepository ?? RecordsRepository();
  }

  /// 履歴削除を実行し、確認を閉じてから完了を SnackBar で知らせる。
  /// 取り消しはできない。
  Future<void> _deleteAllRecords() async {
    await _recordsRepository.deleteAllRecords();
    if (!mounted) {
      return;
    }
    setState(() {
      _showDeleteConfirm = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('履歴を削除しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '設定',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          '興味カテゴリ、通知時刻、履歴を管理します。',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 16),
        const SectionCard(
          title: '提案設定',
          description: '興味カテゴリとカテゴリ別の詳細設定を調整できるようにします。',
        ),
        const SizedBox(height: 12),
        const SectionCard(
          title: '興味カテゴリ',
          description: '音楽、料理、読書、映画から複数選択できるようにします。',
        ),
        const SizedBox(height: 12),
        const SectionCard(
          title: '通知',
          description:
              '通知のON/OFFと通知時刻（デフォルト 17:30）を設定できるようにします。通知をタップすると提案画面を開きます。',
        ),
        const SizedBox(height: 12),
        _buildDeleteHistoryCard(),
      ],
    );
  }

  /// 履歴削除カード：通常時は「削除」ボタン、タップするとインライン確認に切り替わる。
  Widget _buildDeleteHistoryCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _showDeleteConfirm
            ? _buildDeleteConfirmContent()
            : _buildDeleteNormalContent(colorScheme),
      ),
    );
  }

  /// 通常状態：タイトル（赤字）とサブ文言、右に「削除」ボタン。
  Widget _buildDeleteNormalContent(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '履歴削除',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '端末内に保存した履歴を削除',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _showDeleteConfirm = true;
            });
          },
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: const Text('削除'),
        ),
      ],
    );
  }

  /// 確認状態：注意文言と「キャンセル」「削除する」ボタン。
  Widget _buildDeleteConfirmContent() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('本当に削除しますか？この操作は取り消せません。'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonal(
                onPressed: () {
                  setState(() {
                    _showDeleteConfirm = false;
                  });
                },
                child: const Text('キャンセル'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _deleteAllRecords,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: const Text('削除する'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

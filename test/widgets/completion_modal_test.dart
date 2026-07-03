import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimiti_biyori/src/models/suggestion_record.dart';
import 'package:yorimiti_biyori/src/widgets/completion_modal.dart';

/// モーダルを開くボタンだけを持つテスト用ページを組み立てる。
/// 返り値の記録用に ValueNotifier を返す。
Future<ValueNotifier<SuggestionFeedback?>> _pumpModalOpener(
  WidgetTester tester,
) async {
  final returnedFeedback = ValueNotifier<SuggestionFeedback?>(null);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () async {
                returnedFeedback.value = await showCompletionModal(context);
              },
              child: const Text('開く'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('開く'));
  await tester.pumpAndSettle();
  return returnedFeedback;
}

void main() {
  testWidgets('ヘッダー・3つのフィードバック・保存ボタンが表示される', (tester) async {
    await _pumpModalOpener(tester);

    expect(find.text('おつかれさまです'), findsOneWidget);
    expect(find.text('今回のよりみちはどうでしたか？'), findsOneWidget);
    expect(find.text('😊 よかった'), findsOneWidget);
    expect(find.text('🙂 普通'), findsOneWidget);
    expect(find.text('😐 合わなかった'), findsOneWidget);
    expect(find.text('履歴に保存'), findsOneWidget);
  });

  testWidgets('初期選択のまま保存すると good を返す', (tester) async {
    final returnedFeedback = await _pumpModalOpener(tester);

    await tester.tap(find.text('履歴に保存'));
    await tester.pumpAndSettle();

    expect(returnedFeedback.value, SuggestionFeedback.good);
  });

  testWidgets('合わなかったを選んで保存すると bad を返す', (tester) async {
    final returnedFeedback = await _pumpModalOpener(tester);

    await tester.tap(find.text('😐 合わなかった'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('履歴に保存'));
    await tester.pumpAndSettle();

    expect(returnedFeedback.value, SuggestionFeedback.bad);
  });

  testWidgets('保存せずに閉じると null を返す', (tester) async {
    final returnedFeedback = await _pumpModalOpener(tester);

    // モーダル外（背景）をタップして閉じる。
    await tester.tapAt(const Offset(400, 20));
    await tester.pumpAndSettle();

    expect(returnedFeedback.value, isNull);
  });
}

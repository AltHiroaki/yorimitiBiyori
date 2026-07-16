import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimiti_biyori/src/models/suggestion_record.dart';
import 'package:yorimiti_biyori/src/widgets/completion_modal.dart';

/// モーダルを開くボタンだけを持つテスト用ページを組み立て、
/// onSave に渡されたフィードバックを [savedFeedbackLog] に記録する。
Future<List<SuggestionFeedback>> _pumpModalOpener(
  WidgetTester tester, {
  CompletionSaveCallback? onSave,
}) async {
  final savedFeedbackLog = <SuggestionFeedback>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () {
                showCompletionModal(
                  context,
                  onSave: onSave ??
                      (feedback) async {
                        savedFeedbackLog.add(feedback);
                      },
                );
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
  return savedFeedbackLog;
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

  testWidgets('初期選択のまま保存すると good で保存され、成功 SnackBar が出てモーダルが閉じる',
      (tester) async {
    final savedFeedbackLog = await _pumpModalOpener(tester);

    await tester.tap(find.text('履歴に保存'));
    await tester.pumpAndSettle();

    expect(savedFeedbackLog, [SuggestionFeedback.good]);
    expect(find.text('履歴に保存しました'), findsOneWidget);
    expect(find.text('おつかれさまです'), findsNothing);
  });

  testWidgets('合わなかったを選んで保存すると bad で保存される', (tester) async {
    final savedFeedbackLog = await _pumpModalOpener(tester);

    await tester.tap(find.text('😐 合わなかった'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('履歴に保存'));
    await tester.pumpAndSettle();

    expect(savedFeedbackLog, [SuggestionFeedback.bad]);
  });

  testWidgets('保存せずに閉じると onSave は呼ばれない', (tester) async {
    final savedFeedbackLog = await _pumpModalOpener(tester);

    // モーダル外（背景）をタップして閉じる。
    await tester.tapAt(const Offset(400, 20));
    await tester.pumpAndSettle();

    expect(savedFeedbackLog, isEmpty);
    expect(find.text('履歴に保存しました'), findsNothing);
  });

  testWidgets('保存に失敗すると SnackBar を表示し、モーダルは開いたまま再試行できる', (tester) async {
    var attemptCount = 0;
    await _pumpModalOpener(
      tester,
      onSave: (_) async {
        attemptCount += 1;
        throw Exception('storage failed');
      },
    );

    await tester.tap(find.text('履歴に保存'));
    await tester.pumpAndSettle();

    expect(attemptCount, 1);
    expect(find.text('保存に失敗しました'), findsOneWidget);
    // モーダルは開いたままで、ボタンが再度有効になっている。
    expect(find.text('おつかれさまです'), findsOneWidget);
    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '履歴に保存'),
    );
    expect(saveButton.onPressed, isNotNull);
  });

  testWidgets('保存中は「履歴に保存」が無効化され、連打しても二重登録されない', (tester) async {
    final saveCompleter = Completer<void>();
    var saveCount = 0;
    await _pumpModalOpener(
      tester,
      onSave: (_) {
        saveCount += 1;
        return saveCompleter.future;
      },
    );

    // 1回目のタップで保存が始まる（未完了のまま保留）。
    await tester.tap(find.text('履歴に保存'));
    await tester.pump();

    // 保存中はボタンが無効化されている。
    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '履歴に保存'),
    );
    expect(saveButton.onPressed, isNull);

    // 連打しても onSave は追加で呼ばれない。
    await tester.tap(find.text('履歴に保存'), warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.text('履歴に保存'), warnIfMissed: false);
    await tester.pump();

    saveCompleter.complete();
    await tester.pumpAndSettle();

    expect(saveCount, 1);
    expect(find.text('履歴に保存しました'), findsOneWidget);
  });
}

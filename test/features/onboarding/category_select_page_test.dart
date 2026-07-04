import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimiti_biyori/src/features/onboarding/category_select_page.dart';

void main() {
  testWidgets('カテゴリ0件のときは次へが無効になる', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategorySelectPage(
          initialSelectedCategoryIds: const [],
          onNext: (_) {},
        ),
      ),
    );

    expect(find.text('興味のあるよりみちを選んでください'), findsOneWidget);
    expect(find.text('0つ選択中'), findsOneWidget);

    final nextButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '次へ'),
    );
    expect(nextButton.onPressed, isNull);
  });

  testWidgets('MVP 4カテゴリから複数選択して次へ進める', (tester) async {
    List<String>? submittedCategoryIds;

    await tester.pumpWidget(
      MaterialApp(
        home: CategorySelectPage(
          initialSelectedCategoryIds: const [],
          onNext: (selectedCategoryIds) {
            submittedCategoryIds = selectedCategoryIds;
          },
        ),
      ),
    );

    expect(find.widgetWithText(FilterChip, '🎵 音楽'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '🍳 料理'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '📖 読書'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '🎬 映画'), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(4));

    await tester.tap(find.widgetWithText(FilterChip, '🎵 音楽'));
    await tester.tap(find.widgetWithText(FilterChip, '🎬 映画'));
    await tester.pumpAndSettle();

    expect(find.text('2つ選択中'), findsOneWidget);

    final nextButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '次へ'),
    );
    expect(nextButton.onPressed, isNotNull);

    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();

    expect(submittedCategoryIds, ['music', 'movie']);
  });
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yorimichi_biyori/src/app/yorimichi_biyori_app.dart';
import 'package:yorimichi_biyori/src/models/suggestion_record.dart';
import 'package:yorimichi_biyori/src/models/user_settings.dart';
import 'package:yorimichi_biyori/src/repositories/records_repository.dart';
import 'package:yorimichi_biyori/src/repositories/settings_repository.dart';

/// OS の「フォントサイズ最大」相当のストレス値。
/// Android 14 の非線形スケールの上限に合わせて 2.0 とする。
const double _maxTextScale = 2.0;

/// 「表示サイズ最大」相当の狭い論理解像度（幅 360dp クラスの端末を想定）。
const Size _smallPhoneLogicalSize = Size(360, 800);

/// 文字サイズ・表示サイズ最大の環境でアプリを起動する。
/// RenderFlex オーバーフローが起きるとテストフレームワークが例外として検出する。
Future<void> _pumpAppAtMaxTextScale(WidgetTester tester) async {
  tester.view.physicalSize = _smallPhoneLogicalSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = _maxTextScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(const YorimichiBiyoriApp());
  await tester.pumpAndSettle();
}

SuggestionRecord _longTitleRecord() {
  return SuggestionRecord(
    id: 'record_1',
    suggestionId: 'music_jazz_focus',
    suggestionTitle: '作業用にジャズをたっぷり1曲だけ流して気分を整える',
    category: 'music',
    estimatedMinutes: 5,
    status: SuggestionRecordStatus.done,
    feedback: SuggestionFeedback.good,
    createdAt: DateTime.utc(2026, 7, 1, 12),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(firstLaunchCompleted: true).toJson(),
      ),
      recordsPreferenceKey: jsonEncode(
        [_longTitleRecord().toJson(), _longTitleRecord().toJson()],
      ),
    });
    rootBundle.clear();
  });

  testWidgets('文字サイズ最大でも提案タブと完了モーダルが崩れない', (tester) async {
    await _pumpAppAtMaxTextScale(tester);

    expect(find.text('よりみち日和'), findsOneWidget);

    // 文字サイズ最大ではボタンが遅延ビルドの範囲外（画面のはるか下）になるため、
    // タップ可能になるまで ListView をドラッグしてスクロールする。
    final tryButton = find.text('やってみる').hitTestable();
    await tester.dragUntilVisible(
      tryButton,
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(tryButton);
    await tester.pumpAndSettle();

    // やってみる後は実施中カードに切り替わる（issue #48）。
    expect(find.text('実施中のよりみち'), findsOneWidget);

    // 実施中カードの「完了」で完了モーダルを開く。
    final completeButton = find.text('完了').hitTestable();
    await tester.dragUntilVisible(
      completeButton,
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(completeButton);
    await tester.pumpAndSettle();
    expect(find.text('おつかれさまです'), findsOneWidget);

    // 保存せずにモーダルを閉じると実施中カードのまま残る。
    await tester.tapAt(const Offset(180, 20));
    await tester.pumpAndSettle();
    expect(find.text('実施中のよりみち'), findsOneWidget);

    // スキップで通常の提案カードに戻し、「別の提案」も描画する。
    final skipButton = find.text('スキップ').hitTestable();
    await tester.dragUntilVisible(
      skipButton,
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(skipButton);
    await tester.pumpAndSettle();

    final anotherButton = find.text('別の提案').hitTestable();
    await tester.dragUntilVisible(
      anotherButton,
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(anotherButton);
    await tester.pumpAndSettle();
  });

  testWidgets('文字サイズ最大でも履歴タブ（レコードあり）が崩れない', (tester) async {
    await _pumpAppAtMaxTextScale(tester);

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();

    expect(find.text('最近の履歴'), findsOneWidget);
  });

  testWidgets('文字サイズ最大でも履歴タブの空状態が崩れない', (tester) async {
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(firstLaunchCompleted: true).toJson(),
      ),
    });
    rootBundle.clear();
    await _pumpAppAtMaxTextScale(tester);

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();

    expect(find.text('まだ履歴はありません'), findsOneWidget);
  });

  testWidgets('文字サイズ最大でも設定タブ（削除確認展開を含む）が崩れない', (tester) async {
    await _pumpAppAtMaxTextScale(tester);

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('削除'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();

    expect(find.text('本当に削除しますか？この操作は取り消せません。'), findsOneWidget);
  });

  testWidgets('文字サイズ最大でも提案設定画面が崩れない', (tester) async {
    await _pumpAppAtMaxTextScale(tester);

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('提案設定を開く'), 200);
    await tester.tap(find.text('提案設定を開く'));
    await tester.pumpAndSettle();

    expect(find.text('この条件で保存'), findsOneWidget);
  });

  testWidgets('文字サイズ最大でもオンボーディング3画面が崩れない', (tester) async {
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(firstLaunchCompleted: false).toJson(),
      ),
    });
    rootBundle.clear();
    await _pumpAppAtMaxTextScale(tester);

    expect(find.text('よりみち日和へようこそ'), findsOneWidget);

    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();
    expect(find.text('興味のあるよりみちを選んでください'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('次へ'), 200);
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();
    expect(find.text('よりみちのきっかけを通知します'), findsOneWidget);
  });
}

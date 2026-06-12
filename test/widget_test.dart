import 'package:flutter_test/flutter_test.dart';

import 'package:yorimiti_biyori/src/app/yorimiti_biyori_app.dart';

void main() {
  testWidgets('アプリが起動して提案タブが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimitiBiyoriApp());

    // 提案タブ（トップ画面）の内容
    expect(find.text('よりみち日和'), findsOneWidget);
    expect(find.text('空いた時間に、小さなよりみちを。'), findsOneWidget);
    expect(find.text('やってみる'), findsOneWidget);
    expect(find.text('別の提案'), findsOneWidget);
  });

  testWidgets('ボトムナビゲーションは提案・履歴・設定の3タブ', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimitiBiyoriApp());

    expect(find.text('提案'), findsOneWidget);
    expect(find.text('履歴'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets('履歴タブに切り替えると空状態が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimitiBiyoriApp());

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();

    expect(find.text('まだ履歴はありません'), findsOneWidget);
  });
}

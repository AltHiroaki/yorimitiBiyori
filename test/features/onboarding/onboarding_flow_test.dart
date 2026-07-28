import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yorimichi_biyori/src/app/yorimichi_biyori_app.dart';
import 'package:yorimichi_biyori/src/models/user_settings.dart';
import 'package:yorimichi_biyori/src/repositories/settings_repository.dart';

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  UserSettings settings;
  final List<UserSettings> savedSettingsLog = [];

  @override
  Future<UserSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    this.settings = settings;
    savedSettingsLog.add(settings);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
    // widget テスト（FakeAsync）ではネイティブ応答が届かず await が完了しない
    // ため、実 NotificationService が使う flutter_timezone チャネルをモックする。
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_timezone'),
          (methodCall) async => 'Asia/Tokyo',
        );
  });

  testWidgets('初回起動でオンボーディングを完了すると提案画面へ進む', (tester) async {
    final repository = _FakeSettingsRepository(
      const UserSettings(
        selectedCategories: ['music', 'read', 'movie'],
        firstLaunchCompleted: false,
      ),
    );

    await tester.pumpWidget(YorimichiBiyoriApp(settingsRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('よりみち日和へようこそ'), findsOneWidget);
    expect(find.text('ステップ 1 / 3'), findsOneWidget);
    expect(find.text('好きなことを選ぶ'), findsOneWidget);
    expect(find.text('空き時間にそっと届く'), findsOneWidget);
    expect(find.text('やってみたら記録に残る'), findsOneWidget);
    expect(find.text('気分じゃなければ次へ。送った提案はあとで戻せます。'), findsOneWidget);
    expect(
      find.text(
        'まずはこのまま。細かい好み（ジャンルなど）は、'
        '提案を見てから絞り込めます。',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();

    expect(find.text('興味のあるよりみちを選んでください'), findsOneWidget);
    expect(find.text('ステップ 2 / 3'), findsOneWidget);
    expect(
      find.text(
        '選んだカテゴリの中から提案します。'
        '多めに選ぶほど、提案の幅が広がります。あとから変えられます。',
      ),
      findsOneWidget,
    );
    expect(find.text('3つ選択中'), findsOneWidget);

    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();

    expect(find.text('よりみちのきっかけを通知します'), findsOneWidget);
    expect(find.text('ステップ 3 / 3'), findsOneWidget);
    expect(
      find.text(
        '初期設定では17:00〜21:00の間に、1日1回だけお知らせします。'
        '時間帯はあとから設定で変えられます。',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('あとで'));
    await tester.pumpAndSettle();

    expect(repository.savedSettingsLog, hasLength(1));
    final savedSettings = repository.savedSettingsLog.single;
    expect(savedSettings.firstLaunchCompleted, isTrue);
    expect(savedSettings.selectedCategories, ['music', 'read', 'movie']);
    expect(savedSettings.detailSettings, isEmpty);
    expect(savedSettings.notificationEnabled, isFalse);

    expect(find.text('空いた時間に、小さなよりみちを。'), findsOneWidget);
    expect(find.text('提案'), findsOneWidget);
    expect(find.text('履歴'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets('完了時、選択カテゴリの詳細設定は保持し未選択カテゴリの分は落とす', (tester) async {
    final repository = _FakeSettingsRepository(
      const UserSettings(
        selectedCategories: ['music', 'read', 'movie'],
        detailSettings: {
          'music': {
            'genre': ['ジャズ'],
          },
          'cook': {
            'genre': ['和食'],
          },
        },
        firstLaunchCompleted: false,
      ),
    );

    await tester.pumpWidget(YorimichiBiyoriApp(settingsRepository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('あとで'));
    await tester.pumpAndSettle();

    final savedSettings = repository.savedSettingsLog.single;
    expect(savedSettings.detailSettings['music'], {
      'genre': ['ジャズ'],
    });
    // cook はオンボーディングで選択されていないので詳細設定ごと落とす。
    expect(savedSettings.detailSettings.containsKey('cook'), isFalse);
  });

  testWidgets('通知を許可するを選ぶと notificationEnabled が true で保存される', (tester) async {
    final repository = _FakeSettingsRepository(
      const UserSettings(firstLaunchCompleted: false),
    );

    await tester.pumpWidget(YorimichiBiyoriApp(settingsRepository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('通知を許可する'));
    await tester.pumpAndSettle();

    expect(repository.savedSettingsLog.single.notificationEnabled, isTrue);
  });
}

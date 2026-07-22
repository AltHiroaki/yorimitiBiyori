import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimichi_biyori/src/models/user_settings.dart';
import 'package:yorimichi_biyori/src/pages/suggestion_settings_page.dart';
import 'package:yorimichi_biyori/src/repositories/settings_repository.dart';

/// 保存された設定を記録するテスト用フェイク。
class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._settings);

  UserSettings _settings;
  final List<UserSettings> savedSettingsLog = [];

  @override
  Future<UserSettings> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    _settings = settings;
    savedSettingsLog.add(settings);
  }
}

/// ListView の遅延構築で下部セクションが画面外にならないよう、縦長の画面で描画する。
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<_FakeSettingsRepository> _pumpPage(
  WidgetTester tester,
  UserSettings initialSettings,
) async {
  _useTallViewport(tester);
  final repository = _FakeSettingsRepository(initialSettings);
  await tester.pumpWidget(
    MaterialApp(home: SuggestionSettingsPage(settingsRepository: repository)),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('保存済み設定が初期表示に反映される', (tester) async {
    await _pumpPage(
      tester,
      const UserSettings(
        selectedCategories: ['music'],
        detailSettings: {
          'music': {
            'genre': ['ジャズ'],
          },
        },
      ),
    );

    expect(find.text('提案設定'), findsOneWidget);
    expect(find.text('よりみちの条件を調整できます。'), findsOneWidget);
    expect(find.text('1つ選択中'), findsOneWidget);

    // MVP 4カテゴリすべてのチップが表示され、music だけ選択されている。
    expect(find.widgetWithText(FilterChip, '🎵 音楽'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '🍳 料理'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '📖 読書'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '🎬 映画'), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(12));

    // 選択中カテゴリの詳細設定セクションと、保存済みの選択が反映される。
    expect(find.text('🎵 音楽の詳細設定'), findsOneWidget);
    for (final genre in [
      'ロック',
      'ヒップホップ・R&B',
      'アニソン・ゲーム音楽',
      'EDM・テクノ',
    ]) {
      expect(find.widgetWithText(FilterChip, genre), findsOneWidget);
    }
    final jazzChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'ジャズ'),
    );
    expect(jazzChip.selected, isTrue);
  });

  testWidgets('カテゴリの選択で詳細設定セクションが出現・消滅する', (tester) async {
    await _pumpPage(
      tester,
      const UserSettings(selectedCategories: ['music']),
    );

    expect(find.text('🍳 料理の詳細設定'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, '🍳 料理'));
    await tester.pumpAndSettle();
    expect(find.text('2つ選択中'), findsOneWidget);
    expect(find.text('🍳 料理の詳細設定'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, '🍳 料理'));
    await tester.pumpAndSettle();
    expect(find.text('1つ選択中'), findsOneWidget);
    expect(find.text('🍳 料理の詳細設定'), findsNothing);
  });

  testWidgets('料理を選択すると味覚・ジャンルと調理法の2グループが表示される', (tester) async {
    await _pumpPage(
      tester,
      const UserSettings(selectedCategories: ['music']),
    );

    await tester.tap(find.widgetWithText(FilterChip, '🍳 料理'));
    await tester.pumpAndSettle();

    expect(find.text('味覚・ジャンル'), findsOneWidget);
    expect(find.text('調理法'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '和食'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '焼く'), findsOneWidget);
  });

  testWidgets('詳細設定を選んで保存すると選択内容だけが保存される', (tester) async {
    final repository = await _pumpPage(
      tester,
      const UserSettings(
        selectedCategories: ['music'],
        notificationEnabled: false,
        notificationStartTime: '12:15',
        notificationEndTime: '18:45',
        firstLaunchCompleted: true,
        recentSuggestionIds: ['music_jazz_focus'],
      ),
    );

    await tester.tap(find.widgetWithText(FilterChip, 'ジャズ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('この条件で保存'));
    await tester.pumpAndSettle();

    final savedSettings = repository.savedSettingsLog.single;
    expect(savedSettings.selectedCategories, ['music']);
    // 値を選んだグループだけが保存され、未選択グループは含まれない（指定なし）。
    expect(savedSettings.detailSettings, {
      'music': {
        'genre': ['ジャズ'],
      },
    });
    // この画面で編集しないフィールドは温存される。
    expect(savedSettings.notificationEnabled, isFalse);
    expect(savedSettings.notificationStartTime, '12:15');
    expect(savedSettings.notificationEndTime, '18:45');
    expect(savedSettings.firstLaunchCompleted, isTrue);
    expect(savedSettings.recentSuggestionIds, ['music_jazz_focus']);
  });

  testWidgets('選択を外したカテゴリの詳細設定は保存時に刈り込まれる', (tester) async {
    final repository = await _pumpPage(
      tester,
      const UserSettings(
        selectedCategories: ['music', 'movie'],
        detailSettings: {
          'music': {
            'genre': ['ジャズ'],
          },
          'movie': {
            'genre': ['ドラマ'],
          },
        },
      ),
    );

    await tester.tap(find.widgetWithText(FilterChip, '🎬 映画'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('この条件で保存'));
    await tester.pumpAndSettle();

    final savedSettings = repository.savedSettingsLog.single;
    expect(savedSettings.selectedCategories, ['music']);
    expect(savedSettings.detailSettings.containsKey('movie'), isFalse);
  });

  testWidgets('初期設定に戻すとカテゴリが初期値・詳細設定が全解除になる', (tester) async {
    final repository = await _pumpPage(
      tester,
      const UserSettings(
        selectedCategories: ['music', 'cook'],
        detailSettings: {
          'music': {
            'genre': ['ジャズ'],
          },
        },
      ),
    );

    await tester.tap(find.text('初期設定に戻す'));
    await tester.pumpAndSettle();

    expect(find.text('3つ選択中'), findsOneWidget);
    final jazzChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'ジャズ'),
    );
    expect(jazzChip.selected, isFalse);
    // リセットだけでは保存されない。
    expect(repository.savedSettingsLog, isEmpty);
  });

  testWidgets('興味カテゴリに必須マーク（赤い *）が表示される', (tester) async {
    await _pumpPage(
      tester,
      const UserSettings(selectedCategories: ['music']),
    );

    expect(find.text('興味カテゴリ *', findRichText: true), findsOneWidget);
  });

  testWidgets('カテゴリを0件にすると保存が無効になり、必須メッセージが表示される', (tester) async {
    final repository = await _pumpPage(
      tester,
      const UserSettings(selectedCategories: ['music']),
    );

    await tester.tap(find.widgetWithText(FilterChip, '🎵 音楽'));
    await tester.pumpAndSettle();

    expect(find.text('1つ以上選択してください（必須）'), findsOneWidget);
    expect(find.text('0つ選択中'), findsNothing);

    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'この条件で保存'),
    );
    expect(saveButton.onPressed, isNull);

    // 無効なボタンはタップしても保存されない。
    await tester.tap(find.text('この条件で保存'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(repository.savedSettingsLog, isEmpty);

    // 1件選び直すと保存が有効に戻る。
    await tester.tap(find.widgetWithText(FilterChip, '🎵 音楽'));
    await tester.pumpAndSettle();
    expect(find.text('1つ選択中'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'この条件で保存'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('すべて選択で全カテゴリが選択され、すべて解除で0件になる', (tester) async {
    await _pumpPage(
      tester,
      const UserSettings(selectedCategories: ['music']),
    );

    await tester.tap(find.text('すべて選択'));
    await tester.pumpAndSettle();

    expect(find.text('4つ選択中'), findsOneWidget);
    for (final label in ['🎵 音楽', '🍳 料理', '📖 読書', '🎬 映画']) {
      final chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, label),
      );
      expect(chip.selected, isTrue, reason: '$label が選択されているはず');
    }

    // 全選択中はボタンが「すべて解除」に切り替わる。
    expect(find.text('すべて選択'), findsNothing);
    await tester.tap(find.text('すべて解除'));
    await tester.pumpAndSettle();

    expect(find.text('1つ以上選択してください（必須）'), findsOneWidget);
    expect(find.text('すべて選択'), findsOneWidget);
  });

  testWidgets('保存すると画面が閉じる', (tester) async {
    _useTallViewport(tester);
    final repository = _FakeSettingsRepository(const UserSettings());
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SuggestionSettingsPage(
                      settingsRepository: repository,
                    ),
                  ),
                );
              },
              child: const Text('開く'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();
    expect(find.byType(SuggestionSettingsPage), findsOneWidget);

    await tester.tap(find.text('この条件で保存'));
    await tester.pumpAndSettle();

    expect(find.byType(SuggestionSettingsPage), findsNothing);
    expect(repository.savedSettingsLog, hasLength(1));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yorimichi_biyori/src/models/ongoing_suggestion.dart';
import 'package:yorimichi_biyori/src/repositories/ongoing_suggestion_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final ongoing = OngoingSuggestion(
    suggestionId: 'music_jazz_focus',
    startedAt: DateTime.utc(2026, 7, 15, 17, 30),
  );

  test('保存した実施中よりみちを読込で復元できる', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = OngoingSuggestionRepository();

    await repository.saveOngoingSuggestion(ongoing);
    final loaded = await repository.loadOngoingSuggestion();

    expect(loaded, isNotNull);
    expect(loaded!.suggestionId, 'music_jazz_focus');
    expect(loaded.startedAt, DateTime.utc(2026, 7, 15, 17, 30));
  });

  test('未保存のときは null（実施中なし）を返す', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = OngoingSuggestionRepository();

    expect(await repository.loadOngoingSuggestion(), isNull);
  });

  test('解除すると実施中なしに戻る', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = OngoingSuggestionRepository();

    await repository.saveOngoingSuggestion(ongoing);
    await repository.clearOngoingSuggestion();

    expect(await repository.loadOngoingSuggestion(), isNull);
  });

  test('JSON として壊れたデータは null にフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      ongoingSuggestionPreferenceKey: '{{not json',
    });
    final repository = OngoingSuggestionRepository();

    expect(await repository.loadOngoingSuggestion(), isNull);
  });

  test('スキーマバージョンが異なるデータは null にフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      ongoingSuggestionPreferenceKey:
          '{"version": 99, "suggestion_id": "music_a", '
              '"started_at": "2026-07-15T17:30:00.000Z"}',
    });
    final repository = OngoingSuggestionRepository();

    expect(await repository.loadOngoingSuggestion(), isNull);
  });
}

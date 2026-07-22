import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yorimichi_biyori/src/repositories/current_suggestion_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('保存した表示中提案 ID を読み込める', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = CurrentSuggestionRepository();

    await repository.saveCurrentSuggestionId('music_jazz_focus');
    final preferences = await SharedPreferences.getInstance();
    final savedJson = jsonDecode(
      preferences.getString(currentSuggestionPreferenceKey)!,
    ) as Map<String, dynamic>;
    final loadedSuggestionId = await repository.loadCurrentSuggestionId();

    expect(savedJson['version'], currentSuggestionSchemaVersion);
    expect(savedJson['suggestion_id'], 'music_jazz_focus');
    expect(loadedSuggestionId, 'music_jazz_focus');
  });

  test('未保存のときは null を返す', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = CurrentSuggestionRepository();

    final loadedSuggestionId = await repository.loadCurrentSuggestionId();

    expect(loadedSuggestionId, isNull);
  });

  test('壊れた JSON は null にフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      currentSuggestionPreferenceKey: '{{not json',
    });
    final repository = CurrentSuggestionRepository();

    final loadedSuggestionId = await repository.loadCurrentSuggestionId();

    expect(loadedSuggestionId, isNull);
  });

  test('未知の version は null にフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      currentSuggestionPreferenceKey: jsonEncode({
        'version': 999,
        'suggestion_id': 'music_jazz_focus',
      }),
    });
    final repository = CurrentSuggestionRepository();

    final loadedSuggestionId = await repository.loadCurrentSuggestionId();

    expect(loadedSuggestionId, isNull);
  });

  test('suggestion_id が欠けた JSON は null にフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      currentSuggestionPreferenceKey: jsonEncode({
        'version': currentSuggestionSchemaVersion,
      }),
    });
    final repository = CurrentSuggestionRepository();

    final loadedSuggestionId = await repository.loadCurrentSuggestionId();

    expect(loadedSuggestionId, isNull);
  });

  test('表示中提案 ID を削除できる', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = CurrentSuggestionRepository();

    await repository.saveCurrentSuggestionId('music_jazz_focus');
    await repository.clearCurrentSuggestion();
    final loadedSuggestionId = await repository.loadCurrentSuggestionId();

    expect(loadedSuggestionId, isNull);
  });
}

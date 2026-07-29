import 'dart:async';
import 'dart:math';

import '../../models/ongoing_suggestion.dart';
import '../../models/suggestion.dart';
import '../../models/suggestion_record.dart';
import '../../models/user_settings.dart';
import '../../repositories/current_suggestion_repository.dart';
import '../../repositories/ongoing_suggestion_repository.dart';
import '../../repositories/records_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/suggestion_repository.dart';
import 'suggestion_picker.dart';

/// 履歴レコードの ID を作成時刻から組み立てる。
String buildSuggestionRecordId(DateTime createdAt) {
  return 'record_${createdAt.microsecondsSinceEpoch}';
}

/// 提案タブの初期表示に必要なデータ一式。
class SuggestionFlowSnapshot {
  const SuggestionFlowSnapshot({
    required this.suggestions,
    required this.settings,
    required this.ongoingSuggestion,
    required this.ongoingStartedAt,
    required this.restoredSuggestion,
  });

  final List<Suggestion> suggestions;
  final UserSettings settings;

  /// 実施中のよりみち。null は「実施中なし」。
  final Suggestion? ongoingSuggestion;
  final DateTime? ongoingStartedAt;

  /// 前回表示していた提案の復元結果。null なら新規抽選が必要。
  final Suggestion? restoredSuggestion;
}

/// 提案タブの業務ロジック（読込・抽選・復元・直近除外・履歴保存）を担う。
/// 純粋関数（suggestion_picker.dart）とリポジトリ永続化の調停役で、
/// 画面状態は持たない。
class SuggestionFlowService {
  SuggestionFlowService({
    required this._suggestionRepository,
    required this._settingsRepository,
    required this._recordsRepository,
    required this._currentSuggestionRepository,
    required this._ongoingSuggestionRepository,
    required this._random,
  });

  final SuggestionRepository _suggestionRepository;
  final SettingsRepository _settingsRepository;
  final RecordsRepository _recordsRepository;
  final CurrentSuggestionRepository _currentSuggestionRepository;
  final OngoingSuggestionRepository _ongoingSuggestionRepository;
  final Random _random;

  /// 初期表示データを読み込む。
  /// 設定の読込は repository 側でデフォルトへフォールバックするため失敗しない。
  /// 例外になるのは提案JSONデータの読込失敗のみ。
  Future<SuggestionFlowSnapshot> load() async {
    final settings = await _settingsRepository.loadSettings();
    final currentSuggestionId =
        await _currentSuggestionRepository.loadCurrentSuggestionId();
    final ongoing = await _ongoingSuggestionRepository.loadOngoingSuggestion();
    final suggestions = await _suggestionRepository.loadSuggestions();

    final ongoingSuggestion = _resolveOngoingSuggestion(
      suggestions: suggestions,
      ongoing: ongoing,
    );
    final restoredSuggestion = _restoreCurrentSuggestion(
      suggestions: suggestions,
      settings: settings,
      suggestionId: currentSuggestionId,
    );
    return SuggestionFlowSnapshot(
      suggestions: suggestions,
      settings: settings,
      ongoingSuggestion: ongoingSuggestion,
      ongoingStartedAt: ongoingSuggestion == null ? null : ongoing!.startedAt,
      restoredSuggestion: restoredSuggestion,
    );
  }

  /// 保存済みの実施中よりみちを提案データから引き直す。
  /// 提案データの更新で ID が消えていた場合は実施中を解除する（null を返す）。
  Suggestion? _resolveOngoingSuggestion({
    required List<Suggestion> suggestions,
    required OngoingSuggestion? ongoing,
  }) {
    if (ongoing == null) {
      return null;
    }

    for (final suggestion in suggestions) {
      if (suggestion.id == ongoing.suggestionId) {
        return suggestion;
      }
    }
    // 該当データが存在しないため、保存済みの実施中状態も片付ける。
    unawaited(
      _ongoingSuggestionRepository.clearOngoingSuggestion().catchError((_) {}),
    );
    return null;
  }

  /// 前回表示していた提案を、現在の条件に合う候補の中から復元する。
  /// 保存 ID がない・条件に合わなくなった場合は null（新規抽選が必要）。
  Suggestion? _restoreCurrentSuggestion({
    required List<Suggestion> suggestions,
    required UserSettings settings,
    required String? suggestionId,
  }) {
    if (suggestionId == null) {
      return null;
    }

    final matchedSuggestions = filterSuggestions(suggestions, settings);
    for (final suggestion in matchedSuggestions) {
      if (suggestion.id == suggestionId) {
        return suggestion;
      }
    }
    return null;
  }

  /// 現在の設定で候補を絞り込み、weight 付きランダムで 1 件選ぶ。
  /// 選んだ結果（候補なし含む）は次回起動の復元用に永続化する。
  Suggestion? drawSuggestion({
    required List<Suggestion> suggestions,
    required UserSettings settings,
  }) {
    final candidates = excludeRecent(
      filterSuggestions(suggestions, settings),
      settings.recentSuggestionIds,
    );
    final picked = pickWeightedRandom(candidates, _random);
    persistCurrentSuggestion(picked);
    return picked;
  }

  /// 表示中の提案 ID を次回起動の復元用に保存する（null は保存済み ID の削除）。
  /// 永続化の失敗で UI を止めないため、保存は待たずに実行する。
  void persistCurrentSuggestion(Suggestion? suggestion) {
    if (suggestion == null) {
      unawaited(
        _currentSuggestionRepository.clearCurrentSuggestion().catchError(
          (_) {},
        ),
      );
      return;
    }

    unawaited(
      _currentSuggestionRepository
          .saveCurrentSuggestionId(suggestion.id)
          .catchError((_) {}),
    );
  }

  /// 表示した提案 ID を直近リストへ追加した設定を返して永続化する
  /// （重複は寄せ、3件を超えたら古い順に削除）。
  /// 永続化の失敗で UI を止めないため、保存は待たずに実行する。
  UserSettings appendRecentSuggestionId(
    UserSettings settings,
    String suggestionId,
  ) {
    final recentIds = [
      for (final id in settings.recentSuggestionIds)
        if (id != suggestionId) id,
      suggestionId,
    ];
    if (recentIds.length > recentSuggestionLimit) {
      recentIds.removeRange(0, recentIds.length - recentSuggestionLimit);
    }
    final updatedSettings = settings.copyWith(recentSuggestionIds: recentIds);
    unawaited(
      _settingsRepository.saveSettings(updatedSettings).catchError((_) {}),
    );
    return updatedSettings;
  }

  /// 完了した提案を、開始・終了時刻付きの履歴として保存する。
  Future<void> saveDoneRecord(
    Suggestion suggestion, {
    required SuggestionFeedback feedback,
    required DateTime startedAt,
    required DateTime completedAt,
    String? recordId,
  }) async {
    final normalizedStartedAt = startedAt.toUtc();
    final normalizedCompletedAt = completedAt.toUtc();
    final record = SuggestionRecord(
      id: recordId ?? buildSuggestionRecordId(normalizedCompletedAt),
      suggestionId: suggestion.id,
      suggestionTitle: suggestion.title,
      category: suggestion.category,
      estimatedMinutes: suggestion.estimatedMinutes,
      status: SuggestionRecordStatus.done,
      feedback: feedback,
      createdAt: normalizedCompletedAt,
      startedAt: normalizedStartedAt,
      completedAt: normalizedCompletedAt,
    );
    await _recordsRepository.addRecord(record);
  }

  /// スキップした提案を、開始・終了時刻なしの履歴として保存する。
  Future<void> saveSkippedRecord(Suggestion suggestion) async {
    final createdAt = DateTime.now().toUtc();
    final record = SuggestionRecord(
      id: buildSuggestionRecordId(createdAt),
      suggestionId: suggestion.id,
      suggestionTitle: suggestion.title,
      category: suggestion.category,
      estimatedMinutes: suggestion.estimatedMinutes,
      status: SuggestionRecordStatus.skipped,
      feedback: null,
      createdAt: createdAt,
    );
    await _recordsRepository.addRecord(record);
  }

  /// スキップ履歴からの復活で実施中になっていた場合、元のスキップ履歴を
  /// 1件削除する（issue #101）。実施まで至ったのでスキップは挽回されたとみなす。
  /// done 履歴の保存後に呼ぶ。削除に失敗しても done の保存は成立しているため、
  /// 例外は投げず握りつぶす（スキップ行が残るだけで実害はない）。
  Future<void> removeRevivedSkipRecord() async {
    try {
      final ongoing =
          await _ongoingSuggestionRepository.loadOngoingSuggestion();
      final recordId = ongoing?.revivedFromRecordId;
      if (recordId == null) {
        return;
      }
      await _recordsRepository.deleteRecord(recordId);
    } catch (_) {
      // 何もしない。
    }
  }

  /// 実施中のよりみちを永続化する（タブ切替・アプリ再起動でも維持するため）。
  /// 永続化の失敗で UI を止めないため、保存は待たずに実行する。
  void startOngoing(Suggestion suggestion, DateTime startedAt) {
    unawaited(
      _ongoingSuggestionRepository
          .saveOngoingSuggestion(
            OngoingSuggestion(
              suggestionId: suggestion.id,
              startedAt: startedAt,
            ),
          )
          .catchError((_) {}),
    );
  }

  /// 実施中状態の保存を消す（失敗は無視して続行する）。
  Future<void> clearOngoing() async {
    await _ongoingSuggestionRepository
        .clearOngoingSuggestion()
        .catchError((_) {});
  }
}

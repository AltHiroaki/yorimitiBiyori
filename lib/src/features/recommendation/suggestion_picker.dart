import 'dart:math';

import '../../models/suggestion.dart';
import '../../models/user_settings.dart';

const int recentSuggestionLimit = 3;
const String noPreferenceOption = '問わない';

/// ユーザー設定に合う提案だけを返す。
List<Suggestion> filterSuggestions(
  List<Suggestion> suggestions,
  UserSettings settings,
) {
  final selectedCategoryIds = settings.selectedCategories.toSet();
  if (selectedCategoryIds.isEmpty) {
    return const [];
  }

  return suggestions.where((suggestion) {
    if (!selectedCategoryIds.contains(suggestion.category)) {
      return false;
    }
    return _matchesDetailSettings(suggestion, settings.detailSettings);
  }).toList();
}

/// 直近3件を除外する。候補が尽きた場合は直前1件のみ除外に緩和する。
List<Suggestion> excludeRecent(
  List<Suggestion> candidates,
  List<String> recentSuggestionIds,
) {
  if (candidates.isEmpty || recentSuggestionIds.isEmpty) {
    return candidates;
  }

  final recentIdsToExclude = _lastItems(
    recentSuggestionIds,
    recentSuggestionLimit,
  ).toSet();
  final candidatesWithoutRecent = candidates.where((suggestion) {
    return !recentIdsToExclude.contains(suggestion.id);
  }).toList();

  if (candidatesWithoutRecent.isNotEmpty) {
    return candidatesWithoutRecent;
  }

  final lastSuggestionId = recentSuggestionIds.last;
  return candidates.where((suggestion) {
    return suggestion.id != lastSuggestionId;
  }).toList();
}

/// weight を考慮して候補から1件選ぶ。weight が 0 以下の候補は選ばない。
Suggestion? pickWeightedRandom(List<Suggestion> candidates, Random random) {
  final weightedCandidates = candidates.where((suggestion) {
    return suggestion.weight > 0;
  }).toList();

  if (weightedCandidates.isEmpty) {
    return null;
  }

  final totalWeight = weightedCandidates.fold<double>(
    0,
    (sum, suggestion) => sum + suggestion.weight,
  );
  final selectedPoint = random.nextDouble() * totalWeight;

  var cumulativeWeight = 0.0;
  for (final suggestion in weightedCandidates) {
    cumulativeWeight += suggestion.weight;
    if (selectedPoint < cumulativeWeight) {
      return suggestion;
    }
  }

  return weightedCandidates.last;
}

bool _matchesDetailSettings(
  Suggestion suggestion,
  Map<String, Map<String, List<String>>> detailSettings,
) {
  final categoryDetailSettings = detailSettings[suggestion.category];
  if (categoryDetailSettings == null || categoryDetailSettings.isEmpty) {
    return true;
  }

  for (final selectedOptions in categoryDetailSettings.values) {
    final effectiveOptions = _effectiveOptions(selectedOptions);
    if (effectiveOptions.isEmpty) {
      continue;
    }

    final hasMatchingTag = effectiveOptions.any(suggestion.tags.contains);
    if (!hasMatchingTag) {
      return false;
    }

    if (!_matchesBudgetCap(suggestion, effectiveOptions)) {
      return false;
    }
  }
  return true;
}

List<String> _effectiveOptions(List<String> selectedOptions) {
  return selectedOptions.where((option) {
    return option != noPreferenceOption;
  }).toList();
}

bool _matchesBudgetCap(Suggestion suggestion, List<String> selectedOptions) {
  final budgetCaps = selectedOptions
      .map(_budgetCapFromOption)
      .whereType<int>()
      .toList();

  if (budgetCaps.isEmpty) {
    return true;
  }

  final widestBudgetCap = budgetCaps.reduce(max);
  return suggestion.budgetYen <= widestBudgetCap;
}

int? _budgetCapFromOption(String option) {
  if (option == '無料') {
    return 0;
  }

  final match = RegExp(r'(\d+)円').firstMatch(option);
  if (match == null) {
    return null;
  }
  return int.parse(match.group(1)!);
}

List<T> _lastItems<T>(List<T> items, int count) {
  if (items.length <= count) {
    return items;
  }
  return items.sublist(items.length - count);
}

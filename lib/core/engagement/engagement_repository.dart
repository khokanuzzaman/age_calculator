import 'package:shared_preferences/shared_preferences.dart';

import '../utils/date_utils.dart';
import 'engagement_action.dart';

class EngagementState {
  const EngagementState({
    required this.firstSeenDate,
    required this.meaningfulActionCount,
    required this.actionCategories,
    required this.lastReviewPromptDate,
    required this.reviewPromptCount,
    required this.lastPromptedAppVersion,
  });

  final DateTime firstSeenDate;
  final int meaningfulActionCount;
  final Set<String> actionCategories;
  final DateTime? lastReviewPromptDate;
  final int reviewPromptCount;
  final String? lastPromptedAppVersion;

  bool get hasMultipleActionCategories => actionCategories.length >= 2;
}

class EngagementRepository {
  EngagementRepository(this._preferences);

  static const _firstSeenDateKey = 'engagement_first_seen_date';
  static const _actionCountKey = 'engagement_meaningful_action_count';
  static const _categoriesKey = 'engagement_action_categories';
  static const _lastPromptDateKey = 'engagement_last_review_prompt_date';
  static const _promptCountKey = 'engagement_review_prompt_count';
  static const _lastPromptVersionKey = 'engagement_last_prompted_app_version';

  final SharedPreferences _preferences;

  Future<void> ensureInitialized({DateTime? now}) async {
    if (_preferences.containsKey(_firstSeenDateKey)) {
      return;
    }
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    await _preferences.setString(_firstSeenDateKey, _formatDate(today));
  }

  EngagementState load({DateTime? now}) {
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    final rawFirstSeen = _preferences.getString(_firstSeenDateKey);
    final firstSeen = rawFirstSeen == null
        ? today
        : _parseDate(rawFirstSeen) ?? today;
    final rawPromptDate = _preferences.getString(_lastPromptDateKey);
    return EngagementState(
      firstSeenDate: firstSeen,
      meaningfulActionCount: _preferences.getInt(_actionCountKey) ?? 0,
      actionCategories: {
        ...(_preferences.getStringList(_categoriesKey) ?? const <String>[]),
      },
      lastReviewPromptDate: rawPromptDate == null
          ? null
          : _parseDate(rawPromptDate),
      reviewPromptCount: _preferences.getInt(_promptCountKey) ?? 0,
      lastPromptedAppVersion: _preferences.getString(_lastPromptVersionKey),
    );
  }

  Future<EngagementState> record(
    EngagementAction action, {
    DateTime? now,
  }) async {
    await ensureInitialized(now: now);
    final current = load(now: now);
    final today = AppDateUtils.dateOnly(now ?? DateTime.now());
    await _preferences.setInt(
      _actionCountKey,
      current.meaningfulActionCount + 1,
    );
    final categories = {...current.actionCategories, action.analyticsValue};
    await _preferences.setStringList(_categoriesKey, categories.toList());
    return load(now: today);
  }

  bool isEligible({required DateTime now, required String appVersion}) {
    if (!isValidSemanticVersion(appVersion)) {
      return false;
    }
    final state = load(now: now);
    final today = AppDateUtils.dateOnly(now);
    final daysSinceFirstSeen = today.difference(state.firstSeenDate).inDays;
    final daysSincePrompt = state.lastReviewPromptDate == null
        ? 120
        : today.difference(state.lastReviewPromptDate!).inDays;
    return daysSinceFirstSeen >= 3 &&
        state.meaningfulActionCount >= 5 &&
        state.hasMultipleActionCategories &&
        state.lastPromptedAppVersion != appVersion &&
        daysSincePrompt >= 120 &&
        state.reviewPromptCount < 2;
  }

  static bool isValidSemanticVersion(String value) {
    final candidate = value.trim();
    if (candidate.isEmpty ||
        candidate.toLowerCase() == 'unknown' ||
        candidate.toLowerCase() == 'unavailable') {
      return false;
    }
    return RegExp(r'^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$').hasMatch(candidate);
  }

  Future<void> markReviewPromptRequested({
    required DateTime date,
    required String appVersion,
  }) async {
    final today = AppDateUtils.dateOnly(date);
    await _preferences.setString(_lastPromptDateKey, _formatDate(today));
    await _preferences.setInt(
      _promptCountKey,
      (load(now: today).reviewPromptCount + 1),
    );
    await _preferences.setString(_lastPromptVersionKey, appVersion);
  }

  static String _formatDate(DateTime date) {
    final normalized = AppDateUtils.dateOnly(date);
    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
  }

  static DateTime? _parseDate(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed == null ? null : AppDateUtils.dateOnly(parsed);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/analytics/analytics_classification.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/engagement/engagement_action.dart';
import '../../../core/engagement/engagement_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/models/age_result.dart';

const _unset = Object();

final ageCalculatorProvider =
    NotifierProvider<AgeCalculatorNotifier, AgeCalculatorState>(
      AgeCalculatorNotifier.new,
    );

class AgeCalculatorState {
  const AgeCalculatorState({
    required this.asOfDate,
    this.birthDate,
    this.result,
    this.errorMessage,
  });

  final DateTime? birthDate;
  final DateTime asOfDate;
  final AgeResult? result;
  final String? errorMessage;

  AgeCalculatorState copyWith({
    Object? birthDate = _unset,
    DateTime? asOfDate,
    Object? result = _unset,
    Object? errorMessage = _unset,
  }) {
    return AgeCalculatorState(
      birthDate: birthDate == _unset ? this.birthDate : birthDate as DateTime?,
      asOfDate: asOfDate ?? this.asOfDate,
      result: result == _unset ? this.result : result as AgeResult?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class AgeCalculatorNotifier extends Notifier<AgeCalculatorState> {
  static const _lastBirthDateKey = 'last_birth_date';

  @override
  AgeCalculatorState build() {
    return AgeCalculatorState(
      asOfDate: AppDateUtils.dateOnly(DateTime.now()),
      birthDate: _loadLastBirthDate(),
    );
  }

  /// Restores the last calculated date of birth. Safe when preferences are not
  /// available (e.g. unit tests that build the container without an override);
  /// garbage, pre-1900 and future values are ignored.
  DateTime? _loadLastBirthDate() {
    try {
      final raw = ref
          .read(sharedPreferencesProvider)
          .getString(_lastBirthDateKey);
      if (raw == null) {
        return null;
      }
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) {
        return null;
      }
      final date = AppDateUtils.dateOnly(parsed);
      if (date.year < 1900 || AppDateUtils.isAfterDay(date, DateTime.now())) {
        return null;
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  void _saveLastBirthDate(DateTime date) {
    try {
      ref
          .read(sharedPreferencesProvider)
          .setString(_lastBirthDateKey, date.toIso8601String());
    } catch (_) {
      // Remembering the date of birth is a convenience and never blocks the
      // calculation.
    }
  }

  void setBirthDate(DateTime date) {
    final birthDate = AppDateUtils.dateOnly(date);
    final asOfDate = AppDateUtils.isAfterDay(birthDate, state.asOfDate)
        ? birthDate
        : state.asOfDate;

    state = state.copyWith(
      birthDate: birthDate,
      asOfDate: asOfDate,
      result: null,
      errorMessage: null,
    );
  }

  void setAsOfDate(DateTime date) {
    state = state.copyWith(
      asOfDate: AppDateUtils.dateOnly(date),
      result: null,
      errorMessage: null,
    );
  }

  void calculate() {
    final birthDate = state.birthDate;
    final asOfDate = state.asOfDate;

    if (birthDate == null) {
      state = state.copyWith(
        result: null,
        errorMessage: 'Select your date of birth first.',
      );
      return;
    }

    if (AppDateUtils.isAfterDay(birthDate, asOfDate)) {
      state = state.copyWith(
        result: null,
        errorMessage: 'Date of birth cannot be after the calculate date.',
      );
      return;
    }

    final result = AppDateUtils.calculateAge(birthDate, asOfDate);
    _saveLastBirthDate(birthDate);
    state = state.copyWith(result: result, errorMessage: null);
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.ageCalculated,
          parameters: <String, Object>{
            'source': 'age_calculator',
            'is_custom_as_of_date':
                asOfDate != AppDateUtils.dateOnly(DateTime.now()),
            'result_age_group': AnalyticsClassification.ageGroup(result.years),
          },
        );
    try {
      ref
          .read(engagementTrackerProvider)
          .recordMeaningfulActionSafely(EngagementAction.age);
    } catch (_) {
      // Engagement tracking is optional and never blocks the calculation.
    }
  }

  void reset() {
    state = AgeCalculatorState(asOfDate: AppDateUtils.dateOnly(DateTime.now()));
  }
}

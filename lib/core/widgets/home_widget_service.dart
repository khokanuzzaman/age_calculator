import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/theme_mode_notifier.dart';
import '../../features/age_calculator/utils/age_calculation_utils.dart';
import '../utils/date_utils.dart';

/// Pushes the user's current age and birthday countdown to the native Android
/// home-screen widget, keeping the feature code clean.
///
/// The primary birth date is persisted (shared with the reminders feature under
/// the same key) so the widget can be refreshed at launch to reflect today's
/// numbers. All `HomeWidget` calls are best-effort and never throw upward.
class HomeWidgetService {
  HomeWidgetService(this._prefs);

  final SharedPreferences _prefs;

  static const _dobKey = 'primary_birth_date_ms';
  static const _androidWidgetName = 'AgeWidgetProvider';
  static const _keyHasData = 'has_data';
  static const _keyAge = 'age_text';
  static const _keyCountdown = 'countdown_text';

  /// Persists the primary birth date and pushes fresh values to the widget.
  Future<void> setBirthDate(DateTime? birthDate, {DateTime? now}) async {
    if (birthDate == null) {
      await _prefs.remove(_dobKey);
    } else {
      await _prefs.setInt(_dobKey, birthDate.millisecondsSinceEpoch);
    }
    await _push(birthDate, now ?? DateTime.now());
  }

  /// Re-reads the stored birth date and re-pushes — call at launch so the age
  /// and countdown stay current each day.
  Future<void> refresh({DateTime? now}) async {
    final ms = _prefs.getInt(_dobKey);
    final dob = ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    await _push(dob, now ?? DateTime.now());
  }

  Future<void> _push(DateTime? dob, DateTime now) async {
    try {
      if (dob == null) {
        await HomeWidget.saveWidgetData<bool>(_keyHasData, false);
        await HomeWidget.saveWidgetData<String>(_keyAge, 'Set your birthday');
        await HomeWidget.saveWidgetData<String>(
          _keyCountdown,
          'Tap to open Age Calculator',
        );
      } else {
        final data = AgeCalculationUtils.widgetData(dob, now);
        final countdown = data.daysUntilNextBirthday == 0
            ? '🎉 Happy Birthday!'
            : '${AppDateUtils.formatLargeInteger(data.daysUntilNextBirthday)} '
                  'days to birthday';
        await HomeWidget.saveWidgetData<bool>(_keyHasData, true);
        await HomeWidget.saveWidgetData<String>(_keyAge, data.ageText);
        await HomeWidget.saveWidgetData<String>(_keyCountdown, countdown);
      }
      await HomeWidget.updateWidget(androidName: _androidWidgetName);
    } catch (_) {
      // Best-effort: widget updates must never break the app (unsupported
      // platform, missing plugin in tests, etc.).
    }
  }
}

final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService(ref.watch(sharedPreferencesProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../utils/life_calendar_utils.dart';

final lifeCalendarHorizonProvider =
    NotifierProvider<LifeCalendarHorizonNotifier, int>(
      LifeCalendarHorizonNotifier.new,
    );

class LifeCalendarHorizonNotifier extends Notifier<int> {
  static const _key = 'life_calendar_horizon_years';

  @override
  int build() {
    final stored = ref.read(sharedPreferencesProvider).getInt(_key);
    return LifeCalendarUtils.horizonOptions.contains(stored) ? stored! : 90;
  }

  Future<void> setHorizon(int years) async {
    if (!LifeCalendarUtils.horizonOptions.contains(years)) {
      return;
    }
    state = years;
    await ref.read(sharedPreferencesProvider).setInt(_key, years);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../life_timeline/providers/life_events_provider.dart';
import '../../profile/providers/primary_profile_provider.dart';
import '../../saved_birthdays/providers/saved_birthdays_provider.dart';
import '../models/today_dashboard_state.dart';

final todayDashboardProvider = Provider<TodayDashboardState>((ref) {
  return TodayDashboardState.fromSources(
    profile: ref.watch(primaryProfileProvider),
    savedBirthdays: ref.watch(savedBirthdaysProvider),
    lifeEvents: ref.watch(lifeEventsProvider),
  );
});

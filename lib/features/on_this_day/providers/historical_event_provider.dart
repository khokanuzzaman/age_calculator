import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/providers/locale_provider.dart';
import '../models/historical_event_model.dart';
import '../services/historical_event_service.dart';

final historicalEventServiceProvider = Provider<HistoricalEventService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return HistoricalEventService(sharedPreferences: sharedPreferences);
});

final historicalEventsProvider =
    AsyncNotifierProviderFamily<
      HistoricalEventsNotifier,
      List<HistoricalEvent>,
      String
    >(HistoricalEventsNotifier.new);

class HistoricalEventsNotifier
    extends FamilyAsyncNotifier<List<HistoricalEvent>, String> {
  @override
  Future<List<HistoricalEvent>> build(String arg) async {
    final locale = ref.read(appLocaleProvider);
    return ref
        .read(historicalEventServiceProvider)
        .fetchByMonthDay(arg, locale: locale);
  }

  Future<void> refresh() async {
    final locale = ref.read(appLocaleProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(historicalEventServiceProvider)
          .fetchByMonthDay(arg, locale: locale, forceRefresh: true),
    );
  }
}

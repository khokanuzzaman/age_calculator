import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/providers/locale_provider.dart';
import '../model/famous_birthday_model.dart';
import '../service/famous_birthday_service.dart';

export '../../../core/providers/locale_provider.dart' show appLocaleProvider;

final famousBirthdayServiceProvider = Provider<FamousBirthdayService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return FamousBirthdayService(sharedPreferences: sharedPreferences);
});

final famousBirthdaysProvider =
    AsyncNotifierProviderFamily<
      FamousBirthdaysNotifier,
      List<FamousBirthday>,
      String
    >(FamousBirthdaysNotifier.new);

class FamousBirthdaysNotifier
    extends FamilyAsyncNotifier<List<FamousBirthday>, String> {
  @override
  Future<List<FamousBirthday>> build(String arg) async {
    final locale = ref.read(appLocaleProvider);
    return ref
        .read(famousBirthdayServiceProvider)
        .fetchByMonthDay(arg, locale: locale);
  }

  Future<void> refresh() async {
    final locale = ref.read(appLocaleProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(famousBirthdayServiceProvider)
          .fetchByMonthDay(arg, locale: locale, forceRefresh: true),
    );
  }
}

String monthDayFromDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month-$day';
}

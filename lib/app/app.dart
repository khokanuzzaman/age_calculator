import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../features/about/presentation/screens/about_screen.dart';
import '../features/age_calculator/presentation/screens/home_screen.dart'
    as age_calculator;
import '../features/age_difference/screens/age_difference_screen.dart';
import '../features/date_difference/screens/date_difference_screen.dart';
import '../features/famous_birthdays/screens/famous_birthdays_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/leap_year/screens/leap_year_screen.dart';
import '../features/on_this_day/screens/on_this_day_screen.dart';
import '../features/saved_birthdays/screens/saved_birthdays_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import 'app_routes.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_notifier.dart';

class AgeCalculatorApp extends ConsumerWidget {
  const AgeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.ageCalculator: (_) =>
            const age_calculator.AgeCalculatorScreen(),
        AppRoutes.dateDifference: (_) => const DateDifferenceScreen(),
        AppRoutes.ageDifference: (_) => const AgeDifferenceScreen(),
        AppRoutes.leapYear: (_) => const LeapYearScreen(),
        AppRoutes.famousBirthdays: (_) => const FamousBirthdaysScreen(),
        AppRoutes.onThisDay: (_) => const OnThisDayScreen(),
        AppRoutes.savedBirthdays: (_) => const SavedBirthdaysScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
      },
    );
  }
}

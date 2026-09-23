import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ads/ads_provider.dart';
import '../core/ads/app_open_ad_manager.dart';
import '../core/analytics/analytics_event.dart';
import '../core/analytics/app_analytics.dart';
import '../core/analytics/app_analytics_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/notifications/notification_navigation_coordinator.dart';
import '../core/widgets/home_widget_service.dart';
import '../features/about/presentation/screens/about_screen.dart';
import '../features/age_calculator/application/age_calculator_notifier.dart';
import '../features/age_calculator/presentation/screens/home_screen.dart'
    as age_calculator;
import '../features/age_difference/screens/age_difference_screen.dart';
import '../features/date_difference/screens/date_difference_screen.dart';
import '../features/date_tools/screens/countdown_screen.dart';
import '../features/date_tools/screens/date_add_subtract_screen.dart';
import '../features/date_tools/screens/date_tools_screen.dart';
import '../features/date_tools/screens/dob_finder_screen.dart';
import '../features/date_tools/screens/weekday_finder_screen.dart';
import '../features/date_tools/screens/working_days_screen.dart';
import '../features/famous_birthdays/screens/famous_birthdays_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/leap_year/screens/leap_year_screen.dart';
import '../features/life_timeline/providers/life_events_provider.dart';
import '../features/life_timeline/screens/life_timeline_screen.dart';
import '../features/life_calendar/screens/life_calendar_screen.dart';
import '../features/on_this_day/screens/on_this_day_screen.dart';
import '../features/profile/models/primary_profile.dart';
import '../features/profile/providers/primary_profile_provider.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/saved_birthdays/providers/reminders_provider.dart';
import '../features/saved_birthdays/screens/saved_birthdays_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import 'app_routes.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_notifier.dart';

class AgeCalculatorApp extends ConsumerStatefulWidget {
  const AgeCalculatorApp({super.key});

  @override
  ConsumerState<AgeCalculatorApp> createState() => _AgeCalculatorAppState();
}

class _AgeCalculatorAppState extends ConsumerState<AgeCalculatorApp> {
  late final AppLifecycleListener _lifecycleListener;
  bool _hasSyncedInitialProfile = false;

  @override
  void initState() {
    super.initState();
    ref.read(appAnalyticsProvider).logEventSafely(AnalyticsEvent.appOpen);
    notificationNavigationCoordinator.onOpened = (destination) {
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(
            AnalyticsEvent.notificationOpened,
            parameters: <String, Object>{
              'destination': destination.analyticsDestination,
              'reminder_type': destination.reminderType,
            },
          );
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        notificationNavigationCoordinator.flush();
      }
    });
    // Show an App Open ad when the app returns to the foreground (and on the
    // cold-start resume transition when an ad is already loaded). Guards inside
    // the manager prevent stacking with interstitials and enforce the cap.
    _lifecycleListener = AppLifecycleListener(onResume: _onResume);
  }

  void _onResume() {
    AppOpenAdManager.instance.showIfAvailable(
      adsEnabled: ref.read(adsEnabledProvider),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    // The profile is the only product-level source of truth for the user's
    // birthday. Calculator edits remain temporary and never reach this sync.
    ref.listen<PrimaryProfile?>(primaryProfileProvider, (previous, next) {
      _syncPrimaryProfile(next);
    });
    if (!_hasSyncedInitialProfile) {
      _hasSyncedInitialProfile = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncPrimaryProfile(ref.read(primaryProfileProvider));
        }
      });
    }
    ref.listen(lifeEventsProvider, (previous, next) {
      if (previous != next) {
        ref.read(homeWidgetServiceProvider).refresh();
      }
    });

    return MaterialApp(
      navigatorKey: notificationNavigationCoordinator.navigatorKey,
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
        AppRoutes.dateTools: (_) => const DateToolsScreen(),
        AppRoutes.dateAddSubtract: (_) => const DateAddSubtractScreen(),
        AppRoutes.workingDays: (_) => const WorkingDaysScreen(),
        AppRoutes.weekdayFinder: (_) => const WeekdayFinderScreen(),
        AppRoutes.dobFinder: (_) => const DobFinderScreen(),
        AppRoutes.countdown: (_) => const CountdownScreen(),
        AppRoutes.ageDifference: (_) => const AgeDifferenceScreen(),
        AppRoutes.leapYear: (_) => const LeapYearScreen(),
        AppRoutes.famousBirthdays: (_) => const FamousBirthdaysScreen(),
        AppRoutes.onThisDay: (_) => const OnThisDayScreen(),
        AppRoutes.savedBirthdays: (_) => const SavedBirthdaysScreen(),
        AppRoutes.lifeTimeline: (_) => const LifeTimelineScreen(),
        AppRoutes.lifeCalendar: (_) => const LifeCalendarScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
      },
    );
  }

  void _syncPrimaryProfile(PrimaryProfile? profile) {
    final birthDate = profile?.birthDate;
    if (birthDate == null) {
      ref.read(ageCalculatorProvider.notifier).reset();
    } else {
      ref.read(ageCalculatorProvider.notifier).setBirthDate(birthDate);
    }
    unawaited(
      ref
          .read(remindersEnabledProvider.notifier)
          .setOwnBirthDate(birthDate)
          .catchError((_) {}),
    );
    unawaited(ref.read(homeWidgetServiceProvider).refresh().catchError((_) {}));
    unawaited(
      ref.read(remindersEnabledProvider.notifier).ensureScheduleSchema(),
    );
  }
}

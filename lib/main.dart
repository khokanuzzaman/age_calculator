import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/theme/theme_mode_notifier.dart';
import 'core/ads/ads_config.dart';
import 'core/ads/app_open_ad_manager.dart';
import 'core/ads/interstitial_ad_manager.dart';
import 'core/notifications/notification_service.dart';
import 'core/widgets/home_widget_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  final sharedPreferences = await SharedPreferences.getInstance();

  // Best-effort: prepare notifications so scheduled birthday reminders fire.
  try {
    await NotificationService.instance.init();
  } catch (_) {
    // Notifications are non-critical; the app still works without them.
  }

  // Best-effort: refresh the home-screen widget with today's age/countdown.
  try {
    await HomeWidgetService(sharedPreferences).refresh();
  } catch (_) {
    // The widget is optional; never block startup on it.
  }

  // Best-effort: initialize AdMob and preload the first interstitial.
  try {
    if (AdsConfig.testDeviceIds.isNotEmpty) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: AdsConfig.testDeviceIds),
      );
    }
    await MobileAds.instance.initialize();
    InterstitialAdManager.instance.preload();
    AppOpenAdManager.instance.load();
  } catch (_) {
    // Ads are non-critical; never block app startup on them.
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const AgeCalculatorApp(),
    ),
  );
}

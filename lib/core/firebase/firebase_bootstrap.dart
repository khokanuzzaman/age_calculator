import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../analytics/app_analytics.dart';
import '../analytics/firebase_app_analytics.dart';
import '../analytics/noop_analytics.dart';
import '../crashlytics/crash_reporter.dart';

class FirebaseStartup {
  const FirebaseStartup({required this.analytics});

  const FirebaseStartup.fallback() : analytics = const NoopAnalytics();

  final AppAnalytics analytics;
}

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<FirebaseStartup> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final reporter = FirebaseCrashReporter();
      CrashlyticsErrorHandlers.install(reporter);
      return FirebaseStartup(
        analytics: analyticsForInitialization(firebaseInitialized: true),
      );
    } catch (_) {
      return const FirebaseStartup.fallback();
    }
  }

  static AppAnalytics analyticsForInitialization({
    required bool firebaseInitialized,
  }) {
    return firebaseInitialized ? FirebaseAppAnalytics() : const NoopAnalytics();
  }
}

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract interface class CrashReporter {
  Future<void> recordFlutterError(FlutterErrorDetails details);

  Future<void> recordAsyncError(Object error, StackTrace stackTrace);
}

class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> recordAsyncError(Object error, StackTrace stackTrace) async {}

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {}
}

class FirebaseCrashReporter implements CrashReporter {
  FirebaseCrashReporter({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordAsyncError(Object error, StackTrace stackTrace) {
    return _crashlytics.recordError(error, stackTrace, fatal: true);
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) {
    return _crashlytics.recordFlutterFatalError(details);
  }
}

/// Installs global handlers while preserving handlers already registered by
/// Flutter or another app integration.
class CrashlyticsErrorHandlers {
  const CrashlyticsErrorHandlers._();

  static void install(CrashReporter reporter) {
    final previousFlutterError = FlutterError.onError;
    FlutterError.onError = (details) {
      handleFlutterError(
        details: details,
        reporter: reporter,
        previous: previousFlutterError,
      );
    };

    final previousAsyncError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      return handleAsyncError(
        error: error,
        stackTrace: stackTrace,
        reporter: reporter,
        previous: previousAsyncError,
      );
    };
  }

  static void handleFlutterError({
    required FlutterErrorDetails details,
    required CrashReporter reporter,
    FlutterExceptionHandler? previous,
  }) {
    _reportFlutterError(reporter, details);
    previous?.call(details);
  }

  static bool handleAsyncError({
    required Object error,
    required StackTrace stackTrace,
    required CrashReporter reporter,
    bool Function(Object error, StackTrace stackTrace)? previous,
  }) {
    _reportAsyncError(reporter, error, stackTrace);
    return previous?.call(error, stackTrace) ?? true;
  }

  static void _reportFlutterError(
    CrashReporter reporter,
    FlutterErrorDetails details,
  ) {
    try {
      reporter.recordFlutterError(details).catchError((_) {});
    } catch (_) {
      // Reporting must never create an error loop or affect Flutter handling.
    }
  }

  static void _reportAsyncError(
    CrashReporter reporter,
    Object error,
    StackTrace stackTrace,
  ) {
    try {
      reporter.recordAsyncError(error, stackTrace).catchError((_) {});
    } catch (_) {
      // Reporting must never create an error loop or affect Flutter handling.
    }
  }
}

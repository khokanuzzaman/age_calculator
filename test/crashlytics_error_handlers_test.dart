import 'package:age_calculator/core/crashlytics/crash_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCrashReporter implements CrashReporter {
  int flutterErrorCount = 0;
  int asyncErrorCount = 0;

  @override
  Future<void> recordAsyncError(Object error, StackTrace stackTrace) async {
    asyncErrorCount++;
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    flutterErrorCount++;
  }
}

void main() {
  test('forwards Flutter fatal errors and preserves the previous handler', () {
    final reporter = _FakeCrashReporter();
    var previousCalled = false;
    final details = FlutterErrorDetails(
      exception: StateError('unexpected flutter error'),
      stack: StackTrace.current,
    );

    CrashlyticsErrorHandlers.handleFlutterError(
      details: details,
      reporter: reporter,
      previous: (_) => previousCalled = true,
    );

    expect(reporter.flutterErrorCount, 1);
    expect(previousCalled, isTrue);
  });

  test('forwards asynchronous fatal errors and preserves the result', () {
    final reporter = _FakeCrashReporter();
    var previousCalled = false;

    final handled = CrashlyticsErrorHandlers.handleAsyncError(
      error: StateError('unexpected async error'),
      stackTrace: StackTrace.current,
      reporter: reporter,
      previous: (_, __) {
        previousCalled = true;
        return false;
      },
    );

    expect(reporter.asyncErrorCount, 1);
    expect(previousCalled, isTrue);
    expect(handled, isFalse);
  });

  test('no-op reporter is safe when Firebase is unavailable', () async {
    const reporter = NoopCrashReporter();

    await reporter.recordFlutterError(
      FlutterErrorDetails(exception: StateError('ignored')),
    );
    await reporter.recordAsyncError(StateError('ignored'), StackTrace.current);
  });
}

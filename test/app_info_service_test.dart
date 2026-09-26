import 'package:age_calculator/core/app_info/app_info_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats version and build number together', () {
    expect(
      AppInfoService.formatVersion(version: '1.4.0', buildNumber: '10'),
      '1.4.0 (10)',
    );
  });

  test('does not crash when package info cannot be read', () async {
    final service = AppInfoService(
      loadPackageInfo: () async => throw StateError('unavailable'),
    );

    expect(await service.loadVersionLabel(), AppInfoService.unavailableVersion);
    expect(
      await service.loadSemanticVersion(),
      AppInfoService.unavailableVersion,
    );
  });

  test('semantic version is stable and excludes build metadata', () async {
    final service = AppInfoService(loadSemanticVersion: () async => '1.5.0');

    expect(await service.loadSemanticVersion(), '1.5.0');
  });

  test(
    'invalid and unavailable versions are rejected for review use',
    () async {
      for (final value in ['', 'unknown', 'Unavailable', '1.5', '1.5.0 (11)']) {
        final service = AppInfoService(loadSemanticVersion: () async => value);
        expect(
          await service.loadSemanticVersion(),
          AppInfoService.unavailableVersion,
          reason: 'Rejected $value',
        );
      }
    },
  );
}

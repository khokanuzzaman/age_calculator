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
  });
}

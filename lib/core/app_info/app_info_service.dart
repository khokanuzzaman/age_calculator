import 'package:package_info_plus/package_info_plus.dart';

typedef PackageInfoLoader = Future<PackageInfo> Function();

/// Reads the version that was installed with the current app build.
class AppInfoService {
  AppInfoService({PackageInfoLoader? loadPackageInfo})
    : _loadPackageInfo = loadPackageInfo ?? (() => PackageInfo.fromPlatform());

  static const String unavailableVersion = 'Unavailable';

  final PackageInfoLoader _loadPackageInfo;

  Future<String> loadVersionLabel() async {
    try {
      final packageInfo = await _loadPackageInfo();
      return formatVersion(
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      );
    } catch (_) {
      return unavailableVersion;
    }
  }

  static String formatVersion({
    required String version,
    required String buildNumber,
  }) {
    final cleanVersion = version.trim();
    final cleanBuildNumber = buildNumber.trim();
    if (cleanVersion.isEmpty && cleanBuildNumber.isEmpty) {
      return unavailableVersion;
    }
    if (cleanBuildNumber.isEmpty) {
      return cleanVersion;
    }
    if (cleanVersion.isEmpty) {
      return cleanBuildNumber;
    }
    return '$cleanVersion ($cleanBuildNumber)';
  }
}

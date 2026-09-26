import 'package:package_info_plus/package_info_plus.dart';

typedef PackageInfoLoader = Future<PackageInfo> Function();
typedef SemanticVersionLoader = Future<String> Function();

/// Reads the version that was installed with the current app build.
class AppInfoService {
  AppInfoService({
    PackageInfoLoader? loadPackageInfo,
    SemanticVersionLoader? loadSemanticVersion,
  }) : _loadPackageInfo = loadPackageInfo ?? (() => PackageInfo.fromPlatform()),
       _loadSemanticVersion = loadSemanticVersion;

  static const String unavailableVersion = 'Unavailable';

  final PackageInfoLoader _loadPackageInfo;
  final SemanticVersionLoader? _loadSemanticVersion;

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

  /// Returns a stable release version without the build number, or the
  /// unavailable sentinel when package metadata is invalid.
  Future<String> loadSemanticVersion() async {
    try {
      final loader = _loadSemanticVersion;
      final version =
          (loader == null ? (await _loadPackageInfo()).version : await loader())
              .trim();
      return EngagementVersionValidation.isValid(version)
          ? version
          : unavailableVersion;
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

class EngagementVersionValidation {
  const EngagementVersionValidation._();

  static bool isValid(String value) {
    final candidate = value.trim();
    if (candidate.isEmpty ||
        candidate.toLowerCase() == 'unknown' ||
        candidate.toLowerCase() == 'unavailable') {
      return false;
    }
    return RegExp(r'^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$').hasMatch(candidate);
  }
}

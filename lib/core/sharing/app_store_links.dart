import '../constants/app_constants.dart';

/// The public store destinations used by shared content.
class AppStoreLinks {
  AppStoreLinks._();

  static const android =
      'https://play.google.com/store/apps/details?id=me.khokan.agecalculator';
  static const ios =
      'https://apps.apple.com/us/app/age-calculator-zodiac-dob/id6802000455';

  static String captionFor(
    String content, {
    bool includeAttribution = true,
    bool includeStoreLinks = false,
  }) {
    final lines = <String>[content.trim()];
    if (includeAttribution) {
      lines.add('Made with ${AppStrings.appName}');
    }
    if (includeStoreLinks) {
      lines
        ..add('Android: $android')
        ..add('iPhone: $ios');
    }
    return lines.where((line) => line.isNotEmpty).join('\n\n');
  }

  static String get appShareMessage => captionFor(
    '${AppStrings.appName}\n'
    'Age, date, birthday, and time tools.',
    includeStoreLinks: true,
  );
}

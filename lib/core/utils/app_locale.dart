import 'dart:ui';

/// Resolves the user's locale into the signals the data layer needs to serve
/// globally-relevant content: which Wikipedia language editions to query, the
/// label for the "regional" filter, and whether bundled curated data applies.
///
/// This replaces the previous hard-coded Bangladesh/India bias so the app
/// surfaces content relevant to wherever the user actually is.
class AppLocale {
  const AppLocale({required this.languageCode, this.countryCode});

  /// Lower-cased ISO language code, e.g. `en`, `bn`, `hi`, `es`.
  final String languageCode;

  /// Optional ISO country code, e.g. `US`, `BD`, `IN`.
  final String? countryCode;

  bool get isEnglish => languageCode == 'en';

  /// Whether bundled curated data exists for this language. Currently only the
  /// Bangla curated set ships with the app.
  bool get hasCuratedData => languageCode == 'bn';

  /// South-Asian languages get an extra Wikidata enrichment pass, since the
  /// Wikipedia "on this day" feeds under-represent the region.
  bool get isSouthAsian => languageCode == 'bn' || languageCode == 'hi';

  /// Wikipedia language editions to query: the user's language plus English
  /// (English is always included for breadth and de-duplicated when redundant).
  List<String> get wikiLocales =>
      isEnglish ? const ['en'] : [languageCode, 'en'];

  /// Friendly label for the "regional" filter chip and source badge.
  String get regionLabel => _regionLabels[languageCode] ?? 'Regional';

  /// Cache namespace so different languages don't collide in stored results.
  String get cacheKey => languageCode;

  static AppLocale fromPlatform() {
    final locale = PlatformDispatcher.instance.locale;
    return AppLocale(
      languageCode: locale.languageCode.toLowerCase(),
      countryCode: locale.countryCode,
    );
  }

  /// Convenience constants (handy in tests and as a safe fallback).
  static const AppLocale english = AppLocale(languageCode: 'en');
  static const AppLocale bangla = AppLocale(
    languageCode: 'bn',
    countryCode: 'BD',
  );

  static const Map<String, String> _regionLabels = {
    'bn': 'Bangla',
    'hi': 'Hindi',
    'ur': 'Urdu',
    'ta': 'Tamil',
    'es': 'Español',
    'pt': 'Português',
    'fr': 'Français',
    'de': 'Deutsch',
    'ar': 'العربية',
    'id': 'Indonesia',
    'ru': 'Русский',
    'ja': '日本語',
    'zh': '中文',
    'tr': 'Türkçe',
    'it': 'Italiano',
    'ko': '한국어',
    'fa': 'فارسی',
    'vi': 'Tiếng Việt',
  };
}

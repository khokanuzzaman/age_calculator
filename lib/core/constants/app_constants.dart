class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

class AppStrings {
  AppStrings._();

  static const String appName = 'Age Calculator';
  static const String appVersion = '1.1.1';
  static const String appDescription =
      'Calculate exact age, date differences, leap years, and upcoming birthdays with simple offline date math.';
  static const String developerName = 'Md Khokanuzzaman Khokan';
  static const String brandName = 'Troubleshoot Bangla';
  static const String portfolioUrl = 'https://khokan.me';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=me.khokan.agecalculator';
  static const String privacyPolicyUrl =
      'https://khokanuzzaman.github.io/privacy-policy/age-calculator-privacy-policy.html';
  static const String madeWithFlutter = 'Made with Flutter';
  static const String shareAppMessage =
      '$appName\n'
      'Age, date, birthday, and time tools.\n'
      '$playStoreUrl';
}

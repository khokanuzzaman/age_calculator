import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/app_locale.dart';

/// The user's resolved locale, used across the app to serve region-relevant
/// content. Override this in tests to simulate different regions.
final appLocaleProvider = Provider<AppLocale>((ref) => AppLocale.fromPlatform());

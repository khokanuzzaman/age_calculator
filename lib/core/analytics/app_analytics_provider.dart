import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_analytics.dart';
import 'noop_analytics.dart';

final appAnalyticsProvider = Provider<AppAnalytics>(
  (_) => const NoopAnalytics(),
);

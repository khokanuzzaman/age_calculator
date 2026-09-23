import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_info_service.dart';

final appVersionProvider = FutureProvider<String>(
  (_) => AppInfoService().loadVersionLabel(),
);

String displayAppVersion(AsyncValue<String> state) {
  return state.when(
    data: (version) => version,
    loading: () => 'Loading…',
    error: (_, __) => AppInfoService.unavailableVersion,
  );
}

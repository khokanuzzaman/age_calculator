import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme_mode_notifier.dart';

/// Whether ads have been removed (e.g. via a future "Remove ads" purchase).
/// All ad widgets and the interstitial manager respect this flag, so enabling
/// it everywhere is a single switch.
final adsRemovedProvider = NotifierProvider<AdsRemovedNotifier, bool>(
  AdsRemovedNotifier.new,
);

class AdsRemovedNotifier extends Notifier<bool> {
  static const _key = 'ads_removed';

  @override
  bool build() {
    return ref.read(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  Future<void> setRemoved(bool removed) async {
    await ref.read(sharedPreferencesProvider).setBool(_key, removed);
    state = removed;
  }
}

/// True when ads should currently be shown.
final adsEnabledProvider = Provider<bool>((ref) {
  return !ref.watch(adsRemovedProvider);
});

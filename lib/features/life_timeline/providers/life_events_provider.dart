import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../data/life_events_repository.dart';
import '../models/life_event.dart';
import '../utils/life_event_utils.dart';

final lifeEventsRepositoryProvider = Provider<LifeEventsRepository>((ref) {
  return LifeEventsRepository(ref.watch(sharedPreferencesProvider));
});

final lifeEventsProvider =
    NotifierProvider<LifeEventsNotifier, List<LifeEvent>>(
      LifeEventsNotifier.new,
    );

class LifeEventsNotifier extends Notifier<List<LifeEvent>> {
  @override
  List<LifeEvent> build() {
    return LifeEventUtils.sortEvents(
      ref.read(lifeEventsRepositoryProvider).load(),
    );
  }

  Future<void> addOrUpdate(LifeEvent event) async {
    final next = [...state];
    final index = next.indexWhere((item) => item.id == event.id);
    if (index >= 0) {
      next[index] = event;
    } else {
      next.add(event);
    }
    await _persist(next);
  }

  Future<void> remove(String id) async {
    await _persist(state.where((event) => event.id != id).toList());
  }

  Future<void> _persist(List<LifeEvent> events) async {
    final sorted = LifeEventUtils.sortEvents(events);
    await ref.read(lifeEventsRepositoryProvider).save(sorted);
    state = sorted;
  }
}

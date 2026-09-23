import 'package:age_calculator/core/notifications/notification_id_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Life Event reminder IDs are deterministic', () {
    expect(
      NotificationIdFactory.lifeEventReminder('wedding', 7),
      NotificationIdFactory.lifeEventReminder('wedding', 7),
    );
  });

  test('different Life Event lead days receive different IDs', () {
    expect(
      NotificationIdFactory.lifeEventReminder('wedding', 7),
      isNot(NotificationIdFactory.lifeEventReminder('wedding', 1)),
    );
    expect(
      NotificationIdFactory.lifeEventReminder('wedding', 1),
      isNot(NotificationIdFactory.lifeEventReminder('wedding', 0)),
    );
  });

  test('Life Event namespace does not collide with other reminders', () {
    final lifeEvent = NotificationIdFactory.lifeEventReminder('same', 0);
    final savedBirthday = NotificationIdFactory.savedBirthday('same', 0);
    final ownBirthday = NotificationIdFactory.ownBirthday(0);
    const milestone = NotificationIdFactory.milestone;

    expect({lifeEvent, savedBirthday, ownBirthday, milestone}, hasLength(4));
  });
}

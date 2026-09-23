import 'package:age_calculator/core/notifications/notification_destination.dart';
import 'package:age_calculator/core/notifications/notification_navigation_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('person notification payload round trips a local ID', () {
    const destination = NotificationDestination.person('person-123');
    final payload = NotificationDestinationCodec.encode(destination);

    expect(payload, 'person:person-123');
    expect(NotificationDestinationCodec.decode(payload)?.localId, 'person-123');
  });

  test('malformed notification payloads fail safely', () {
    expect(NotificationDestinationCodec.decode(null), isNull);
    expect(NotificationDestinationCodec.decode(''), isNull);
    expect(NotificationDestinationCodec.decode('person:'), isNull);
    expect(
      NotificationDestinationCodec.decode('person:name:with-colon'),
      isNull,
    );
    expect(NotificationDestinationCodec.decode('unknown:destination'), isNull);
  });

  test('supported non-person destinations stay fixed and non-personal', () {
    expect(
      NotificationDestinationCodec.encode(
        const NotificationDestination.profile(),
      ),
      'profile',
    );
    expect(
      NotificationDestinationCodec.encode(
        const NotificationDestination.lifeTimeline(),
      ),
      'life_timeline',
    );
    expect(
      NotificationDestinationCodec.encode(
        const NotificationDestination.milestone(),
      ),
      'milestone',
    );
    expect(
      NotificationDestinationCodec.encode(
        const NotificationDestination.person('abc'),
      ),
      isNot(contains('name')),
    );
  });

  testWidgets(
    'cold-start destination queues and duplicate taps do not navigate twice',
    (tester) async {
      final key = GlobalKey<NavigatorState>();
      final coordinator = NotificationNavigationCoordinator(navigatorKey: key);
      var opened = 0;
      coordinator.onOpened = (_) => opened++;
      coordinator.handlePayload('profile');

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          home: const Scaffold(body: Text('Home')),
          routes: {'/profile': (_) => const Scaffold(body: Text('Profile'))},
        ),
      );
      coordinator.flush();
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(opened, 1);
      coordinator.handlePayload('profile');
      expect(opened, 1);
    },
  );
}

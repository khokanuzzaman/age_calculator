import 'package:age_calculator/core/analytics/analytics_event.dart';
import 'package:age_calculator/core/analytics/app_analytics.dart';
import 'package:age_calculator/core/analytics/app_analytics_provider.dart';
import 'package:age_calculator/features/birthday_wishes/models/birthday_share_card_model.dart';
import 'package:age_calculator/features/birthday_wishes/models/birthday_wish_category.dart';
import 'package:age_calculator/features/birthday_wishes/utils/birthday_wish_service.dart';
import 'package:age_calculator/features/saved_birthdays/models/saved_person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every category has curated templates', () {
    for (final category in BirthdayWishCategory.values) {
      expect(BirthdayWishService.templates[category], isNotEmpty);
      expect(
        BirthdayWishService.templates[category]!.length,
        greaterThanOrEqualTo(6),
      );
    }
  });

  test('template placeholders resolve without unresolved values', () {
    for (final category in BirthdayWishCategory.values) {
      for (
        var index = 0;
        index < BirthdayWishService.templates[category]!.length;
        index++
      ) {
        final wish = BirthdayWishService.create(
          category: category,
          index: index,
          name: 'Sam',
          age: 42,
          useAge: true,
        );
        expect(wish.text, isNot(contains('{name}')));
        expect(wish.text, isNot(contains('{age}')));
        expect(wish.text, contains('Sam'));
      }
    }
  });

  test('age is optional and only appears when selected and supported', () {
    final withAge = BirthdayWishService.create(
      category: BirthdayWishCategory.warm,
      index: 0,
      name: 'Sam',
      age: 42,
      useAge: true,
    );
    final withoutAge = BirthdayWishService.create(
      category: BirthdayWishCategory.warm,
      index: 0,
      name: 'Sam',
      age: 42,
    );
    expect(withAge.text, contains('42'));
    expect(withoutAge.text, isNot(contains('42')));
  });

  test('next and previous template selection is deterministic', () {
    const category = BirthdayWishCategory.short;
    final count = BirthdayWishService.templates[category]!.length;
    expect(BirthdayWishService.nextIndex(category, count - 1), 0);
    expect(BirthdayWishService.previousIndex(category, 0), count - 1);
  });

  test(
    'birthday-today and countdown card models contain no private metadata',
    () {
      final person = SavedPerson(
        id: 'local-id',
        name: 'Mom',
        birthDate: DateTime(1968, 10, 5),
      );
      final today = BirthdayShareCardModel.fromPerson(
        person,
        DateTime(2026, 10, 5),
      );
      final upcoming = BirthdayShareCardModel.fromPerson(
        person,
        DateTime(2026, 9, 23),
      );

      expect(today.type, BirthdayShareCardType.today);
      expect(today.age, 58);
      expect(upcoming.type, BirthdayShareCardType.countdown);
      expect(upcoming.daysRemaining, 12);
      expect(today.shareText, isNot(contains('1968')));
      expect(today.shareText, isNot(contains('local-id')));
      expect(today.shareText, isNot(contains('relation')));
    },
  );

  testWidgets('manually edited wish text is not sent to analytics', (
    tester,
  ) async {
    final analytics = _RecordingAnalytics();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appAnalyticsProvider.overrideWithValue(analytics)],
        child: const MaterialApp(home: SizedBox()),
      ),
    );
    analytics.logEventSafely(
      AnalyticsEvent.birthdayWishCopied,
      parameters: const <String, Object>{'category': 'warm'},
    );
    await tester.pump();

    expect(
      analytics.parameters.values.expand((map) => map.values),
      isNot(contains('private edited message')),
    );
    expect(
      analytics.parameters.values.expand((map) => map.keys),
      isNot(contains('message')),
    );
  });
}

class _RecordingAnalytics implements AppAnalytics {
  final events = <AnalyticsEvent>[];
  final parameters = <AnalyticsEvent, Map<String, Object>>{};

  @override
  Future<void> logEvent(
    AnalyticsEvent event, {
    AnalyticsParameters parameters = const <String, Object>{},
  }) async {
    events.add(event);
    this.parameters[event] = Map<String, Object>.from(parameters);
  }
}

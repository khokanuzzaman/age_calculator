import 'package:age_calculator/app/app.dart';
import 'package:age_calculator/app/theme/theme_mode_notifier.dart';
import 'package:age_calculator/core/app_info/app_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> createContainer({
    Map<String, Object> preferences = const {},
  }) async {
    SharedPreferences.setMockInitialValues(preferences);
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        appVersionProvider.overrideWith((ref) async => '1.4.0 (10)'),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    Map<String, Object> preferences = const {},
  }) async {
    final container = await createContainer(preferences: preferences);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AgeCalculatorApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows dashboard tools on launch', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('Age Calculator'), findsWidgets);
    expect(find.text('Age, date, birthday, and time tools'), findsOneWidget);
    expect(find.text('Date Tools'), findsOneWidget);
    expect(find.text('Life Timeline'), findsOneWidget);
    expect(find.text('Life Calendar'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Settings'), 400);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('first-time dashboard keeps setup and tools compact', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpApp(tester);

    expect(find.text('Age Calculator'), findsWidgets);
    expect(find.text('Make Age Calculator yours'), findsOneWidget);
    expect(find.text('Set My Birthday'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Calculate Your Age'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Calculate Your Age')).dy,
      lessThan(844),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'personalized dashboard separates Today and a long profile name',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      tester.binding.platformDispatcher.textScaleFactorTestValue = 1.35;
      addTearDown(() {
        tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
        return tester.binding.setSurfaceSize(null);
      });
      await pumpApp(
        tester,
        preferences: {
          'primary_birth_date_ms': DateTime(1990, 1, 1).millisecondsSinceEpoch,
          'primary_profile_display_name': 'Md Khokanuzzaman Khokan',
        },
      );

      final nameFinder = find.text('Md Khokanuzzaman Khokan');
      expect(find.text('Today'), findsOneWidget);
      expect(nameFinder, findsOneWidget);
      expect(tester.widget<Text>(nameFinder).maxLines, 2);
      expect(find.text('Your age today'), findsOneWidget);
      expect(find.text('NEXT BIRTHDAY'), findsOneWidget);
      expect(find.text('NEXT MILESTONE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('personalized dashboard respects the light color scheme', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      preferences: {
        'theme_mode': 'light',
        'primary_birth_date_ms': DateTime(1990, 1, 1).millisecondsSinceEpoch,
        'primary_profile_display_name': 'Khokan',
      },
    );

    final ageLabel = find.text('Your age today');
    expect(ageLabel, findsOneWidget);
    expect(Theme.of(tester.element(ageLabel)).brightness, Brightness.light);
    expect(find.text('NEXT BIRTHDAY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the life timeline from the dashboard', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Life Timeline'));
    await tester.pumpAndSettle();

    expect(find.text('Your timeline is empty'), findsOneWidget);
    expect(find.text('Add event'), findsOneWidget);
  });

  testWidgets('opens the life calendar from the dashboard', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Life Calendar').last);
    await tester.pumpAndSettle();

    expect(find.text('Set your birthday first'), findsOneWidget);
    expect(find.text('Set My Birthday'), findsOneWidget);
  });

  testWidgets('renders the life calendar grid after a birthday is set', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      preferences: {
        'primary_birth_date_ms': DateTime(1990, 1, 1).millisecondsSinceEpoch,
      },
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Life Calendar').last);
    await tester.pumpAndSettle();

    expect(find.text('Your life in weeks'), findsOneWidget);
    expect(find.text('90 years'), findsOneWidget);
    expect(find.byTooltip('Week 1'), findsOneWidget);
  });

  testWidgets('opens age calculator screen from the dashboard', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Calculate Your Age'));
    await tester.pumpAndSettle();

    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Calculate As Of'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Age, date, birthday, and time tools'), findsOneWidget);
  });

  testWidgets('Date Tools hub exposes every date utility', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Date Tools'));
    await tester.pumpAndSettle();

    for (final title in [
      'Date Difference',
      'Date Add / Subtract',
      'Working Days',
      'Weekday Finder',
      'DOB Finder',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Countdown'), findsOneWidget);
    expect(find.text('Leap Year'), findsOneWidget);
  });

  testWidgets('opens date difference screen from the dashboard', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Date Tools'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Date Difference'));
    await tester.pumpAndSettle();

    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);
    expect(
      find.text('Find the exact gap between any two dates.'),
      findsOneWidget,
    );
  });

  testWidgets('navigates to About screen from overflow menu', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('About').last);
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Version 1.4.0 (10)'), findsOneWidget);
    expect(find.text('Made with Flutter'), findsOneWidget);
  });

  testWidgets('opens My People with search and filters', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      preferences: {
        'saved_birthdays_v1':
            '[{"id":"mom","name":"Mom","birthDateMs":631152000000,"emoji":"🎂"}]',
      },
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My People'));
    await tester.pumpAndSettle();

    expect(find.text('My People'), findsOneWidget);
    expect(find.text('Search people'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Mom'), findsOneWidget);
  });

  testWidgets('opens a Life Event detail from the timeline', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      preferences: {
        'life_events_v1':
            '[{"id":"wedding","title":"Wedding","eventDateMs":1557360000000,"emoji":"❤️","reminderEnabled":true,"category":"relationship","recurrence":"yearly","reminderLeadDays":[1,0]}]',
      },
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Life Timeline'));
    await tester.pumpAndSettle();

    expect(find.text('Wedding'), findsOneWidget);
    await tester.tap(find.text('Wedding'));
    await tester.pumpAndSettle();

    expect(find.text('Moment details'), findsOneWidget);
    expect(find.text('Every year'), findsOneWidget);
  });
}

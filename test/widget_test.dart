import 'package:age_calculator/app/app.dart';
import 'package:age_calculator/app/theme/theme_mode_notifier.dart';
import 'package:age_calculator/core/app_info/app_info_provider.dart';
import 'package:age_calculator/features/age_calculator/application/age_calculator_notifier.dart';
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
    expect(find.text('Date Difference'), findsOneWidget);
    expect(find.text('Life Timeline'), findsOneWidget);
    expect(find.text('Life Calendar'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('opens the life timeline from the dashboard', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Life Timeline'));
    await tester.pumpAndSettle();

    expect(find.text('Your timeline is empty'), findsOneWidget);
    expect(find.text('Add event'), findsOneWidget);
  });

  testWidgets('opens the life calendar from the dashboard', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Life Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('Set your birthday first'), findsOneWidget);
    expect(find.text('Calculate your age'), findsOneWidget);
  });

  testWidgets('renders the life calendar grid after a birthday is set', (
    WidgetTester tester,
  ) async {
    final container = await createContainer();
    container
        .read(ageCalculatorProvider.notifier)
        .setBirthDate(DateTime(1990, 1, 1));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AgeCalculatorApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Life Calendar'));
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

  testWidgets('opens date difference screen from the dashboard', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

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
}

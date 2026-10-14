import 'package:age_calculator/features/age_calculator/domain/models/age_result.dart';
import 'package:age_calculator/features/age_calculator/models/age_milestone_model.dart';
import 'package:age_calculator/features/age_calculator/widgets/life_insights_cards.dart';
import 'package:age_calculator/features/age_calculator/widgets/life_stats_card.dart';
import 'package:age_calculator/features/age_calculator/widgets/milestones_tab.dart';
import 'package:age_calculator/features/age_calculator/widgets/result_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

LifeStats _stats() => const LifeStats(
  totalDays: 100,
  totalHours: 2400,
  totalMinutes: 144000,
  totalSeconds: 8640000,
  yearProgress: 50,
  monthProgress: 50,
  weekProgress: 50,
);

void main() {
  testWidgets('LifeStatsCard ticks and cancels its timer on dispose', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(LifeStatsCard(stats: _stats(), birthDate: DateTime(1995, 6, 15))),
    );

    // Let a few ticks run; the card must keep building without errors.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Total seconds lived'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Removing the widget must cancel the periodic timer (a pending timer
    // would fail the test at teardown).
    await tester.pumpWidget(_host(const SizedBox.shrink()));
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('LifeStatsCard without a birth date shows the given stats', (
    tester,
  ) async {
    await tester.pumpWidget(_host(LifeStatsCard(stats: _stats())));
    await tester.pumpAndSettle();

    expect(find.text('2,400'), findsOneWidget);
    expect(find.text('144,000'), findsOneWidget);
    expect(find.text('8,640,000'), findsOneWidget);
  });

  testWidgets('LifeInsightsCard shows generation and birth season', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(LifeInsightsCard(birthDate: DateTime(1995, 8, 15))),
    );

    expect(find.text('About Your Birth'), findsOneWidget);
    expect(find.text('Millennial'), findsOneWidget);
    expect(find.text('Summer'), findsOneWidget);
    expect(
      find.text('Season shown for the northern hemisphere.'),
      findsOneWidget,
    );
  });

  testWidgets('MilestonesTab shows life stages and upcoming birthdays', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        MilestonesTab(
          milestones: const <AgeMilestone>[],
          birthDate: DateTime(1995, 8, 15),
        ),
      ),
    );

    expect(find.text('Life Stages'), findsOneWidget);
    expect(find.text('Upcoming Birthdays'), findsOneWidget);
    expect(find.text('Adulthood (18)'), findsOneWidget);
  });

  testWidgets('ResultSummaryCard copies the exact age', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    final result = AgeResult(
      years: 30,
      months: 10,
      days: 5,
      totalDays: 11000,
      totalHours: 264000,
      totalMinutes: 15840000,
      daysUntilNextBirthday: 40,
      dayOfWeekBorn: 'Thursday',
      birthDate: DateTime(1995, 6, 15),
      asOfDate: DateTime(2026, 4, 20),
    );

    await tester.pumpWidget(
      _host(ResultSummaryCard(result: result, onReset: () {})),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Copy exact age'));
    await tester.pump();

    expect(copied, '30 years, 10 months, 5 days');
    expect(find.text('Age copied'), findsOneWidget);
  });
}

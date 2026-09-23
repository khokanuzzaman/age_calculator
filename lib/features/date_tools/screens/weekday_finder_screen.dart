import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/engagement/engagement_action.dart';
import '../../../core/engagement/engagement_provider.dart';
import '../../../features/profile/providers/primary_profile_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../utils/weekday_finder_utils.dart';

class WeekdayFinderScreen extends ConsumerStatefulWidget {
  const WeekdayFinderScreen({super.key});

  @override
  ConsumerState<WeekdayFinderScreen> createState() =>
      _WeekdayFinderScreenState();
}

class _WeekdayFinderScreenState extends ConsumerState<WeekdayFinderScreen> {
  DateTime _date = _today();
  WeekdayFinderResult? _result;

  static DateTime _today() =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void _calculate({String source = 'manual'}) {
    final result = WeekdayFinderUtils.calculate(_date);
    setState(() => _result = result);
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.weekdayFinderUsed,
          parameters: <String, Object>{'source': source},
        );
    ref
        .read(engagementTrackerProvider)
        .recordMeaningfulActionSafely(EngagementAction.dateTools);
  }

  @override
  Widget build(BuildContext context) {
    final profileDate = ref.watch(primaryProfileProvider)?.birthDate;
    return Scaffold(
      appBar: AppBar(title: const Text('Weekday Finder')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                AppCard(
                  child: Column(
                    children: [
                      AppDateField(
                        label: 'Date',
                        value: _date,
                        onChanged: (date) => setState(() {
                          _date = date;
                          _result = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          ActionChip(
                            label: const Text('Today'),
                            onPressed: () {
                              setState(() => _date = _today());
                              _calculate();
                            },
                          ),
                          if (profileDate != null)
                            ActionChip(
                              label: const Text('My Birthday'),
                              onPressed: () {
                                setState(() => _date = profileDate);
                                _calculate(source: 'profile');
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                AppPrimaryButton(
                  label: 'Find Weekday',
                  icon: Icons.calendar_view_day_outlined,
                  onPressed: _calculate,
                ),
                if (_result != null) ...[
                  const SizedBox(height: AppSpacing.base),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _result!.weekday,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(DateFormat('d MMMM yyyy').format(_result!.date)),
                        if (_result!.isLeapYear) const Text('Leap year'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

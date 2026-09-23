import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/engagement/engagement_action.dart';
import '../../../core/engagement/engagement_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../utils/working_days_utils.dart';

class WorkingDaysScreen extends ConsumerStatefulWidget {
  const WorkingDaysScreen({super.key});

  @override
  ConsumerState<WorkingDaysScreen> createState() => _WorkingDaysScreenState();
}

class _WorkingDaysScreenState extends ConsumerState<WorkingDaysScreen> {
  DateTime _start = _today();
  DateTime _end = _today();
  WeekendPattern _weekend = WeekendPattern.satSun;
  WorkingDaysResult? _result;

  static DateTime _today() =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void _calculate() {
    try {
      final result = WorkingDaysUtils.calculate(
        startDate: _start,
        endDate: _end,
        weekendPattern: _weekend,
      );
      setState(() => _result = result);
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(
            AnalyticsEvent.workingDaysUsed,
            parameters: <String, Object>{
              'weekend_pattern': _weekend.analyticsValue,
            },
          );
      ref
          .read(engagementTrackerProvider)
          .recordMeaningfulActionSafely(EngagementAction.dateTools);
    } on ArgumentError catch (error) {
      _message(
        error.message?.toString() ??
            'Start date must be on or before end date.',
      );
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Working Days')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                const Text(
                  'Count both start and end dates. Public holidays are not included.',
                ),
                const SizedBox(height: AppSpacing.base),
                AppCard(
                  child: Column(
                    children: [
                      AppDateField(
                        label: 'Start Date',
                        value: _start,
                        onChanged: (date) => setState(() {
                          _start = date;
                          _result = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppDateField(
                        label: 'End Date',
                        value: _end,
                        onChanged: (date) => setState(() {
                          _end = date;
                          _result = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<WeekendPattern>(
                        initialValue: _weekend,
                        decoration: const InputDecoration(
                          labelText: 'Weekend pattern',
                        ),
                        items: WeekendPattern.values
                            .map(
                              (pattern) => DropdownMenuItem(
                                value: pattern,
                                child: Text(pattern.label),
                              ),
                            )
                            .toList(),
                        onChanged: (pattern) => setState(() {
                          _weekend = pattern ?? WeekendPattern.satSun;
                          _result = null;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                AppPrimaryButton(
                  label: 'Calculate',
                  icon: Icons.calculate_outlined,
                  onPressed: _calculate,
                ),
                if (_result != null) ...[
                  const SizedBox(height: AppSpacing.base),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${_result!.workingDays} working days',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${_result!.totalCalendarDays} calendar days · ${_result!.weekendDays} weekend days',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Weekend: ${_result!.weekendPattern.label}'),
                        Text(
                          'Inclusive range · public holidays are not included.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
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

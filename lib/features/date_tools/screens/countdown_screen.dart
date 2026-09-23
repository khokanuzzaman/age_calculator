import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
import '../../age_calculator/utils/age_calculation_utils.dart';
import '../../profile/providers/primary_profile_provider.dart';
import '../utils/countdown_utils.dart';

class CountdownScreen extends ConsumerStatefulWidget {
  const CountdownScreen({super.key});

  @override
  ConsumerState<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends ConsumerState<CountdownScreen> {
  DateTime _target = _today();
  CountdownResult? _result;

  static DateTime _today() =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void _calculate() {
    final result = CountdownUtils.calculate(
      targetDate: _target,
      today: _today(),
    );
    setState(() => _result = result);
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.countdownUsed,
          parameters: <String, Object>{
            'direction': result.direction.analyticsValue,
          },
        );
    ref
        .read(engagementTrackerProvider)
        .recordMeaningfulActionSafely(EngagementAction.dateTools);
  }

  String _headline(CountdownResult result) {
    return switch (result.direction) {
      CountdownDirection.future =>
        '${result.totalDays} ${result.totalDays == 1 ? 'day' : 'days'} to go',
      CountdownDirection.past =>
        '${result.totalDays} ${result.totalDays == 1 ? 'day' : 'days'} ago',
      CountdownDirection.today => 'Today',
    };
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(primaryProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                const Text(
                  'Choose a date to see how far away it is. This is a date-only countdown.',
                ),
                const SizedBox(height: AppSpacing.base),
                AppCard(
                  child: Column(
                    children: [
                      AppDateField(
                        label: 'Target Date',
                        value: _target,
                        onChanged: (date) => setState(() {
                          _target = date;
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
                              setState(() => _target = _today());
                              _calculate();
                            },
                          ),
                          if (profile != null) ...[
                            ActionChip(
                              label: const Text('My Birthday'),
                              onPressed: () {
                                setState(() => _target = profile.birthDate);
                                _calculate();
                              },
                            ),
                            ActionChip(
                              label: const Text('Next Birthday'),
                              onPressed: () {
                                setState(
                                  () => _target =
                                      AgeCalculationUtils.nextBirthday(
                                        profile.birthDate,
                                        _today(),
                                      ),
                                );
                                _calculate();
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                AppPrimaryButton(
                  label: 'Start Countdown',
                  icon: Icons.hourglass_bottom_outlined,
                  onPressed: _calculate,
                ),
                if (_result != null) ...[
                  const SizedBox(height: AppSpacing.base),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _headline(_result!),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          '${_result!.weeks} weeks ${_result!.remainingDays} days',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppDateUtilsPresentation.format(_result!.targetDate),
                        ),
                        Text(_result!.weekday),
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

class AppDateUtilsPresentation {
  AppDateUtilsPresentation._();

  static String format(DateTime date) => DateFormat('d MMMM yyyy').format(date);
}

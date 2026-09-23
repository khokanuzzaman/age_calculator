import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_classification.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/animated_result_card.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../utils/date_difference_utils.dart';
import '../widgets/date_difference_result_card.dart';

class DateDifferenceScreen extends ConsumerStatefulWidget {
  const DateDifferenceScreen({super.key});

  @override
  ConsumerState<DateDifferenceScreen> createState() =>
      _DateDifferenceScreenState();
}

class _DateDifferenceScreenState extends ConsumerState<DateDifferenceScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateDifferenceResult? _result;

  void _calculate() {
    final start = _startDate;
    final end = _endDate;

    if (start == null || end == null) {
      _showMessage('Select both dates first.');
      return;
    }

    if (!DateDifferenceUtils.isValidRange(start, end)) {
      _showMessage(DateDifferenceUtils.validationMessage);
      return;
    }

    final result = DateDifferenceUtils.calculate(start, end);
    setState(() {
      _result = result;
    });
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.dateDifferenceUsed,
          parameters: <String, Object>{
            'direction': AnalyticsClassification.dateDifferenceDirection(
              start,
              end,
            ),
          },
        );
  }

  void _reset() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _result = null;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Date Difference')),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            const Positioned.fill(child: AppScreenBackdrop()),
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Find the exact gap between any two dates.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    AppDateField(
                      label: 'Start Date',
                      value: _startDate,
                      onChanged: (date) => setState(() => _startDate = date),
                      firstDate: DateTime(1900),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDateField(
                      label: 'End Date',
                      value: _endDate,
                      onChanged: (date) => setState(() => _endDate = date),
                      firstDate: DateTime(1900),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppPrimaryButton(
                      label: 'Calculate',
                      icon: Icons.calculate_outlined,
                      onPressed: _calculate,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedSwitcher(
                      duration: AppDurations.normal,
                      child: _result == null
                          ? const _EmptyState()
                          : AnimatedResultCard(
                              key: ValueKey(_result.hashCode),
                              child: DateDifferenceResultCard(result: _result!),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        'Select two dates to see the difference.',
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

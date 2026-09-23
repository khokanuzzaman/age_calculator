import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/engagement/engagement_action.dart';
import '../../../core/engagement/engagement_provider.dart';
import '../../../core/sharing/share_engine.dart';
import '../../../core/sharing/share_payload.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../utils/date_add_subtract_utils.dart';

class DateAddSubtractScreen extends ConsumerStatefulWidget {
  const DateAddSubtractScreen({super.key});

  @override
  ConsumerState<DateAddSubtractScreen> createState() =>
      _DateAddSubtractScreenState();
}

class _DateAddSubtractScreenState extends ConsumerState<DateAddSubtractScreen> {
  DateTime _startDate = _today();
  DateOperation _operation = DateOperation.add;
  final _years = TextEditingController(text: '0');
  final _months = TextEditingController(text: '0');
  final _weeks = TextEditingController(text: '0');
  final _days = TextEditingController(text: '0');
  DateAddSubtractResult? _result;

  static DateTime _today() =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void dispose() {
    _years.dispose();
    _months.dispose();
    _weeks.dispose();
    _days.dispose();
    super.dispose();
  }

  void _calculate() {
    final values = [
      _years,
      _months,
      _weeks,
      _days,
    ].map((controller) => int.tryParse(controller.text.trim())).toList();
    if (values.any((value) => value == null || value < 0)) {
      _message('Enter zero or a positive whole number in every amount.');
      return;
    }
    final amounts = values.cast<int>();
    if (amounts.every((value) => value == 0)) {
      _message('Enter at least one non-zero amount.');
      return;
    }
    try {
      final result = DateAddSubtractUtils.calculate(
        startDate: _startDate,
        operation: _operation,
        years: amounts[0],
        months: amounts[1],
        weeks: amounts[2],
        days: amounts[3],
      );
      setState(() => _result = result);
      ref
          .read(appAnalyticsProvider)
          .logEventSafely(
            AnalyticsEvent.dateAddSubtractUsed,
            parameters: <String, Object>{
              'operation': _operation == DateOperation.add ? 'add' : 'subtract',
              'has_years': amounts[0] > 0,
              'has_months': amounts[1] > 0,
              'has_weeks': amounts[2] > 0,
              'has_days': amounts[3] > 0,
            },
          );
      ref
          .read(engagementTrackerProvider)
          .recordMeaningfulActionSafely(EngagementAction.dateTools);
    } on RangeError catch (error) {
      _message(error.message.toString());
    }
  }

  Future<void> _share() async {
    final result = _result;
    if (result == null) return;
    final text = _summary(result);
    try {
      await ShareEngine().share(
        context,
        SharePayload(text: '$text\nCalculated with Age Calculator.'),
      );
      ref
          .read(engagementTrackerProvider)
          .recordMeaningfulActionSafely(EngagementAction.share);
    } catch (_) {
      _message('Sharing is unavailable right now.');
    }
  }

  String _summary(DateAddSubtractResult result) {
    final operation = result.operation == DateOperation.add ? '+' : '-';
    final parts = <String>[];
    if (result.years > 0) parts.add('${result.years}y');
    if (result.months > 0) parts.add('${result.months}mo');
    if (result.weeks > 0) parts.add('${result.weeks}w');
    if (result.days > 0) parts.add('${result.days}d');
    return '${DateFormat('d MMMM yyyy').format(result.startDate)} $operation '
        '${parts.join(' ')} = ${DateFormat('d MMMM yyyy').format(result.resultDate)}\n'
        '${_weekday(result.resultDate)}';
  }

  String _weekday(DateTime date) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[date.weekday - 1];
  }

  void _reset() {
    setState(() {
      _startDate = _today();
      _operation = DateOperation.add;
      for (final controller in [_years, _months, _weeks, _days]) {
        controller.text = '0';
      }
      _result = null;
    });
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date Add / Subtract')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                const Text(
                  'Years and months are applied first, then weeks and days.',
                ),
                const SizedBox(height: AppSpacing.base),
                AppCard(
                  child: Column(
                    children: [
                      AppDateField(
                        label: 'Start Date',
                        value: _startDate,
                        onChanged: (date) => setState(() {
                          _startDate = date;
                          _result = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SegmentedButton<DateOperation>(
                        segments: const [
                          ButtonSegment(
                            value: DateOperation.add,
                            label: Text('Add'),
                            icon: Icon(Icons.add),
                          ),
                          ButtonSegment(
                            value: DateOperation.subtract,
                            label: Text('Subtract'),
                            icon: Icon(Icons.remove),
                          ),
                        ],
                        selected: {_operation},
                        onSelectionChanged: (value) => setState(() {
                          _operation = value.first;
                          _result = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(child: _amountField('Years', _years)),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: _amountField('Months', _months)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(child: _amountField('Weeks', _weeks)),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: _amountField('Days', _days)),
                        ],
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
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
                if (_result != null) ...[
                  const SizedBox(height: AppSpacing.base),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Result Date',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          DateFormat('d MMMM yyyy').format(_result!.resultDate),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          _weekday(_result!.resultDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(_summary(_result!)),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: _share,
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share Result'),
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

  Widget _amountField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
    );
  }
}

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
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../utils/dob_finder_utils.dart';

class DobFinderScreen extends ConsumerStatefulWidget {
  const DobFinderScreen({super.key});

  @override
  ConsumerState<DobFinderScreen> createState() => _DobFinderScreenState();
}

class _DobFinderScreenState extends ConsumerState<DobFinderScreen> {
  DateTime _asOf = _today();
  final _years = TextEditingController(text: '30');
  final _months = TextEditingController(text: '0');
  final _days = TextEditingController(text: '0');
  DobFinderResult? _result;

  static DateTime _today() =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void dispose() {
    _years.dispose();
    _months.dispose();
    _days.dispose();
    super.dispose();
  }

  void _calculate() {
    final years = int.tryParse(_years.text.trim());
    final months = int.tryParse(_months.text.trim());
    final days = int.tryParse(_days.text.trim());
    if (years == null || months == null || days == null) {
      _message('Enter a whole number for each age component.');
      return;
    }
    final error = DobFinderUtils.validate(
      years: years,
      months: months,
      days: days,
    );
    if (error != null) {
      _message(error);
      return;
    }
    final result = DobFinderUtils.calculate(
      asOfDate: _asOf,
      years: years,
      months: months,
      days: days,
    );
    if (result == null) {
      _message('That exact age cannot be represented for this date.');
      return;
    }
    setState(() => _result = result);
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.dobFinderUsed,
          parameters: <String, Object>{
            'has_years': years > 0,
            'has_months': months > 0,
            'has_days': days > 0,
          },
        );
    ref
        .read(engagementTrackerProvider)
        .recordMeaningfulActionSafely(EngagementAction.dateTools);
  }

  void _message(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DOB Finder')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                const Text(
                  'Find a birth date from an exact age on a reference date.',
                ),
                const SizedBox(height: AppSpacing.base),
                AppCard(
                  child: Column(
                    children: [
                      AppDateField(
                        label: 'Age as of',
                        value: _asOf,
                        onChanged: (date) => setState(() {
                          _asOf = date;
                          _result = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(child: _field('Years', _years)),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: _field('Months', _months)),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: _field('Days', _days)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                AppPrimaryButton(
                  label: 'Find Date of Birth',
                  icon: Icons.cake_outlined,
                  onPressed: _calculate,
                ),
                if (_result != null) ...[
                  const SizedBox(height: AppSpacing.base),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Calculated Date of Birth',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          DateFormat('d MMMM yyyy').format(_result!.birthDate),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(AppDateUtils.weekdayName(_result!.birthDate)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Based on an exact age of ${_result!.years} years, ${_result!.months} months, and ${_result!.days} days on ${DateFormat('d MMMM yyyy').format(_result!.asOfDate)}.',
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

  Widget _field(String label, TextEditingController controller) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(labelText: label),
  );
}

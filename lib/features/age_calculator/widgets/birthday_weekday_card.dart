import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/animated_count_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/age_milestone_model.dart';

class BirthdayWeekdayCard extends StatelessWidget {
  const BirthdayWeekdayCard({super.key, required this.details});

  final BirthdayDetails details;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Birthday Details', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.base),
          _Line(label: 'Born on', value: details.bornWeekday),
          const SizedBox(height: AppSpacing.sm),
          _Line(
            label: 'Next birthday',
            value:
                '${details.nextBirthdayWeekday}, ${DateFormat('d MMMM yyyy').format(details.nextBirthdayDate)}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _Line(
            label: 'Days until next birthday',
            valueWidget: AnimatedCountText(
              value: details.daysUntilNextBirthday,
              suffix: ' days',
              duration: const Duration(milliseconds: 900),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        valueWidget ??
            Text(
              value!,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../models/age_milestone_model.dart';
import 'birthday_weekday_card.dart';
import 'life_facts_card.dart';
import 'life_stats_card.dart';
import 'numerology_card.dart';
import 'zodiac_card.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.birthDate,
    required this.stats,
    required this.birthdayDetails,
  });

  final DateTime birthDate;
  final LifeStats stats;
  final BirthdayDetails birthdayDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LifeStatsCard(stats: stats),
        const SizedBox(height: AppSpacing.base),
        ZodiacCard(birthDate: birthDate),
        const SizedBox(height: AppSpacing.base),
        NumerologyCard(birthDate: birthDate),
        const SizedBox(height: AppSpacing.base),
        LifeFactsCard(totalDays: stats.totalDays),
        const SizedBox(height: AppSpacing.base),
        BirthdayWeekdayCard(details: birthdayDetails),
      ],
    );
  }
}

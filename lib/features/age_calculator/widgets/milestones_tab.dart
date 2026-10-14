import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../models/age_milestone_model.dart';
import 'age_milestone_card.dart';
import 'life_insights_cards.dart';

class MilestonesTab extends StatelessWidget {
  const MilestonesTab({
    super.key,
    required this.milestones,
    required this.birthDate,
  });

  final List<AgeMilestone> milestones;
  final DateTime birthDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AgeMilestoneCard(milestones: milestones),
        const SizedBox(height: AppSpacing.base),
        LifeStagesCard(birthDate: birthDate),
        const SizedBox(height: AppSpacing.base),
        UpcomingBirthdaysCard(birthDate: birthDate),
      ],
    );
  }
}

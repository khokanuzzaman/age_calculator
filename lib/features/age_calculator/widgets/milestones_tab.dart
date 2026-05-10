import 'package:flutter/material.dart';

import '../models/age_milestone_model.dart';
import 'age_milestone_card.dart';

class MilestonesTab extends StatelessWidget {
  const MilestonesTab({super.key, required this.milestones});

  final List<AgeMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    return AgeMilestoneCard(milestones: milestones);
  }
}

import 'package:flutter/material.dart';

import '../../on_this_day/widgets/history_on_this_day_card.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.monthDay});

  final String monthDay;

  @override
  Widget build(BuildContext context) {
    return HistoryOnThisDayCard(monthDay: monthDay);
  }
}

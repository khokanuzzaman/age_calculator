import 'package:flutter/material.dart';

import '../../famous_birthdays/widgets/famous_birthdays_card.dart';

class FamousTab extends StatelessWidget {
  const FamousTab({super.key, required this.monthDay});

  final String monthDay;

  @override
  Widget build(BuildContext context) {
    return FamousBirthdaysCard(monthDay: monthDay);
  }
}

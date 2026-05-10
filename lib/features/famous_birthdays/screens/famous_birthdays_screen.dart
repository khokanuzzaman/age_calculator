import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../provider/famous_birthday_provider.dart';
import '../widgets/famous_birthdays_card.dart';

class FamousBirthdaysScreen extends StatefulWidget {
  const FamousBirthdaysScreen({super.key});

  @override
  State<FamousBirthdaysScreen> createState() => _FamousBirthdaysScreenState();
}

class _FamousBirthdaysScreenState extends State<FamousBirthdaysScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthDay = monthDayFromDate(_selectedDate);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Famous Birthdays')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.huge,
              ),
              children: [
                AppDateField(
                  label: 'Pick a date',
                  value: _selectedDate,
                  helperText: 'See who was born on this day',
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 1),
                  onChanged: (date) => setState(() => _selectedDate = date),
                ),
                const SizedBox(height: AppSpacing.base),
                FamousBirthdaysCard(monthDay: monthDay),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

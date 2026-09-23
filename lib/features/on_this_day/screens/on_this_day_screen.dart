import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../famous_birthdays/provider/famous_birthday_provider.dart'
    show monthDayFromDate;
import '../widgets/history_on_this_day_card.dart';

class OnThisDayScreen extends ConsumerStatefulWidget {
  const OnThisDayScreen({super.key, this.source = 'home'});

  final String source;

  @override
  ConsumerState<OnThisDayScreen> createState() => _OnThisDayScreenState();
}

class _OnThisDayScreenState extends ConsumerState<OnThisDayScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.onThisDayOpened,
          parameters: <String, Object>{'source': widget.source},
        );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthDay = monthDayFromDate(_selectedDate);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('History on This Day')),
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
                  helperText: 'See what happened on this day',
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 1),
                  onChanged: (date) => setState(() => _selectedDate = date),
                ),
                const SizedBox(height: AppSpacing.base),
                HistoryOnThisDayCard(monthDay: monthDay),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

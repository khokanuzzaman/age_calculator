import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_routes.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';

class DateToolsScreen extends ConsumerStatefulWidget {
  const DateToolsScreen({super.key});

  @override
  ConsumerState<DateToolsScreen> createState() => _DateToolsScreenState();
}

class _DateToolsScreenState extends ConsumerState<DateToolsScreen> {
  @override
  void initState() {
    super.initState();
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(AnalyticsEvent.dateToolsOpened);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date Tools')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                Text(
                  'Practical date math for everyday planning.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                for (final tool in _tools) ...[
                  _DateToolTile(tool: tool),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateToolDefinition {
  const _DateToolDefinition({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  final String title;
  final String description;
  final IconData icon;
  final String route;
}

const _tools = [
  _DateToolDefinition(
    title: 'Date Difference',
    description: 'See the exact gap between two dates',
    icon: Icons.date_range_outlined,
    route: AppRoutes.dateDifference,
  ),
  _DateToolDefinition(
    title: 'Date Add / Subtract',
    description: 'Move a date forward or backward',
    icon: Icons.exposure_plus_1_outlined,
    route: AppRoutes.dateAddSubtract,
  ),
  _DateToolDefinition(
    title: 'Working Days',
    description: 'Count weekdays between two dates',
    icon: Icons.business_center_outlined,
    route: AppRoutes.workingDays,
  ),
  _DateToolDefinition(
    title: 'Weekday Finder',
    description: 'Find the day of the week for any date',
    icon: Icons.today_outlined,
    route: AppRoutes.weekdayFinder,
  ),
  _DateToolDefinition(
    title: 'DOB Finder',
    description: 'Calculate a birth date from an exact age',
    icon: Icons.cake_outlined,
    route: AppRoutes.dobFinder,
  ),
  _DateToolDefinition(
    title: 'Countdown',
    description: 'See how long until or since a date',
    icon: Icons.hourglass_bottom_outlined,
    route: AppRoutes.countdown,
  ),
  _DateToolDefinition(
    title: 'Leap Year',
    description: 'Check whether a year has an extra day',
    icon: Icons.event_repeat_outlined,
    route: AppRoutes.leapYear,
  ),
];

class _DateToolTile extends StatelessWidget {
  const _DateToolTile({required this.tool});

  final _DateToolDefinition tool;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Icon(tool.icon),
        ),
        title: Text(tool.title),
        subtitle: Text(tool.description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pushNamed(tool.route),
      ),
    );
  }
}

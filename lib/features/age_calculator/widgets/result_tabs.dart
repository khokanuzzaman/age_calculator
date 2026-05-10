import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/animated_result_card.dart';
import '../models/age_milestone_model.dart';
import 'famous_tab.dart';
import 'history_tab.dart';
import 'milestones_tab.dart';
import 'overview_tab.dart';

class ResultTabs extends StatefulWidget {
  const ResultTabs({
    super.key,
    required this.monthDay,
    required this.birthDate,
    required this.stats,
    required this.birthdayDetails,
    required this.milestones,
  });

  final String monthDay;
  final DateTime birthDate;
  final LifeStats stats;
  final BirthdayDetails birthdayDetails;
  final List<AgeMilestone> milestones;

  @override
  State<ResultTabs> createState() => _ResultTabsState();
}

class _ResultTabsState extends State<ResultTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<int> _visitedTabs = <int>{0};
  final Set<int> _animatedTabs = <int>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) {
          _visitedTabs.add(_tabController.index);
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              labelColor: scheme.onPrimaryContainer,
              unselectedLabelColor: scheme.onSurfaceVariant,
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Milestones'),
                Tab(text: 'Famous'),
                Tab(text: 'History'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        IndexedStack(
          index: _tabController.index,
          children: [
            _buildTabContent(
              index: 0,
              delay: const Duration(milliseconds: 120),
              child: OverviewTab(
                birthDate: widget.birthDate,
                stats: widget.stats,
                birthdayDetails: widget.birthdayDetails,
              ),
            ),
            _buildTabContent(
              index: 1,
              delay: const Duration(milliseconds: 160),
              child: MilestonesTab(milestones: widget.milestones),
            ),
            _buildTabContent(
              index: 2,
              delay: const Duration(milliseconds: 200),
              child: FamousTab(monthDay: widget.monthDay),
            ),
            _buildTabContent(
              index: 3,
              delay: const Duration(milliseconds: 240),
              child: HistoryTab(monthDay: widget.monthDay),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabContent({
    required int index,
    required Duration delay,
    required Widget child,
  }) {
    final visible = _tabController.index == index;
    final built = _visitedTabs.contains(index) || visible;
    if (!built) {
      return const SizedBox.shrink();
    }

    final shouldAnimate = !_animatedTabs.contains(index);
    if (shouldAnimate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _animatedTabs.add(index);
      });
    }

    return AnimatedResultCard(
      delay: delay,
      animate: shouldAnimate,
      child: child,
    );
  }
}

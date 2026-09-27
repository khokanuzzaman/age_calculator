import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/sharing/app_store_links.dart';
import '../../../core/sharing/share_engine.dart';
import '../../../core/sharing/share_payload.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_entrance.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../../shared/widgets/theme_mode_bottom_sheet.dart';
import '../../age_calculator/application/age_calculator_notifier.dart';
import '../../saved_birthdays/screens/person_detail_screen.dart';
import '../../life_timeline/screens/life_event_detail_screen.dart';
import '../models/today_dashboard_state.dart';
import '../providers/today_dashboard_provider.dart';
import '../widgets/tool_menu_card.dart';

enum _HomeMenuAction { theme, privacyPolicy, shareApp, about }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(AnalyticsEvent.todayDashboardViewed);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final dashboard = ref.watch(todayDashboardProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const BannerAdWidget(),
      appBar: AppBar(
        actions: [
          PopupMenuButton<_HomeMenuAction>(
            tooltip: 'More options',
            onSelected: (action) async {
              switch (action) {
                case _HomeMenuAction.theme:
                  await showThemeModeBottomSheet(
                    context: context,
                    currentThemeMode: themeMode,
                    onSelected: (mode) {
                      ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    },
                  );
                  break;
                case _HomeMenuAction.privacyPolicy:
                  await _openLink(AppStrings.privacyPolicyUrl);
                  break;
                case _HomeMenuAction.shareApp:
                  ref
                      .read(appAnalyticsProvider)
                      .logEventSafely(
                        AnalyticsEvent.appShareClicked,
                        parameters: const <String, Object>{
                          'source': 'home_menu',
                        },
                      );
                  await ShareEngine().share(
                    context,
                    SharePayload(
                      text: AppStoreLinks.appShareMessage,
                      subject: AppStrings.appName,
                    ),
                  );
                  break;
                case _HomeMenuAction.about:
                  if (context.mounted) {
                    await Navigator.of(context).pushNamed(AppRoutes.about);
                  }
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.theme,
                child: _MenuTile(icon: Icons.palette_outlined, label: 'Theme'),
              ),
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.privacyPolicy,
                child: _MenuTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                ),
              ),
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.shareApp,
                child: _MenuTile(
                  icon: Icons.share_outlined,
                  label: 'Share App',
                ),
              ),
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.about,
                child: _MenuTile(icon: Icons.info_outline, label: 'About'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.xs,
                    AppSpacing.base,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AppEntrance(
                      child: _DashboardHeader(dashboard: dashboard),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AppEntrance(
                      delay: const Duration(milliseconds: 45),
                      child: AnimatedSwitcher(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : AppDurations.normal,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.015),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(dashboard.hasProfile),
                          child: dashboard.hasProfile
                              ? _PersonalizedContent(
                                  dashboard: dashboard,
                                  onProfile: _openProfile,
                                  onCalculateAge: () =>
                                      _openAgeCalculator(dashboard),
                                  onUpcoming: _openUpcoming,
                                  onQuickAction: _openTarget,
                                )
                              : _SetupCard(
                                  onSetBirthday: _openProfile,
                                  onCalculateAge: () =>
                                      _openAgeCalculator(dashboard),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.md,
                      AppSpacing.base,
                      AppSpacing.huge,
                    ),
                    child: _buildTools(dashboard),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTools(TodayDashboardState dashboard) {
    final primaryTools = <Widget>[
      ToolMenuCard(
        featured: true,
        accent: _ToolColors.age,
        title: 'Calculate Your Age',
        description: 'Exact age, zodiac, milestones & lifetime totals',
        icon: Icons.cake_outlined,
        onTap: () => _openAgeCalculator(dashboard),
      ),
      _tool(
        featured: true,
        accent: _ToolColors.saved,
        title: 'My People',
        description: 'Track the people you love',
        icon: Icons.favorite_outline,
        route: AppRoutes.savedBirthdays,
        target: 'my_people',
      ),
      _tool(
        featured: true,
        accent: _ToolColors.timeline,
        title: 'Life Timeline',
        description: 'Age at important moments',
        icon: Icons.timeline_outlined,
        route: AppRoutes.lifeTimeline,
      ),
      _tool(
        featured: true,
        accent: _ToolColors.calendar,
        title: 'Life Calendar',
        description: 'See your life in weeks',
        icon: Icons.grid_view_rounded,
        route: AppRoutes.lifeCalendar,
      ),
    ];
    final utilityTools = <Widget>[
      _tool(
        accent: _ToolColors.dateDiff,
        title: 'Date Tools',
        description: 'Date math in one place',
        icon: Icons.build_circle_outlined,
        route: AppRoutes.dateTools,
      ),
      _tool(
        accent: _ToolColors.ageDiff,
        title: 'Age Difference',
        description: 'Compare two ages',
        icon: Icons.people_alt_outlined,
        route: AppRoutes.ageDifference,
      ),
      _tool(
        accent: _ToolColors.famous,
        title: 'Famous Birthdays',
        description: 'Who shares your day',
        icon: Icons.star_outline,
        route: AppRoutes.famousBirthdays,
      ),
      _tool(
        accent: _ToolColors.history,
        title: 'On This Day',
        description: 'History by date',
        icon: Icons.history_outlined,
        route: AppRoutes.onThisDay,
      ),
      _tool(
        accent: _ToolColors.settings,
        title: 'Settings',
        description: 'Theme & preferences',
        icon: Icons.settings_outlined,
        route: AppRoutes.settings,
      ),
      _tool(
        accent: _ToolColors.about,
        title: 'About',
        description: 'Developer & privacy',
        icon: Icons.info_outline,
        route: AppRoutes.about,
      ),
    ];

    Widget toolWrap(List<Widget> cards, double width) {
      final cardWidth = (width - AppSpacing.md) / 2;
      return Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          for (final card in cards) SizedBox(width: cardWidth, child: card),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppEntrance(
          delay: Duration(milliseconds: 105),
          child: _SectionLabel(title: 'Tools', icon: Icons.grid_view_rounded),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Personal',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppEntrance(
          delay: const Duration(milliseconds: 145),
          child: LayoutBuilder(
            builder: (context, constraints) => toolWrap(
              primaryTools,
              constraints.maxWidth.clamp(0, 740).toDouble(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Date & more',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppEntrance(
          delay: const Duration(milliseconds: 180),
          child: LayoutBuilder(
            builder: (context, constraints) => toolWrap(
              utilityTools,
              constraints.maxWidth.clamp(0, 740).toDouble(),
            ),
          ),
        ),
      ],
    );
  }

  ToolMenuCard _tool({
    required Color accent,
    required String title,
    required String description,
    required IconData icon,
    required String route,
    bool featured = false,
    String? target,
  }) {
    return ToolMenuCard(
      accent: accent,
      title: title,
      description: description,
      icon: icon,
      featured: featured,
      onTap: () {
        _logAction(target ?? route.replaceFirst('/', ''));
        Navigator.of(context).pushNamed(route);
      },
    );
  }

  void _openProfile() {
    _logAction('profile');
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }

  void _openAgeCalculator(TodayDashboardState dashboard) {
    final birthDate = dashboard.profile?.birthDate;
    if (birthDate != null) {
      ref.read(ageCalculatorProvider.notifier).setBirthDate(birthDate);
    }
    _logAction('age_calculator');
    Navigator.of(context).pushNamed(AppRoutes.ageCalculator);
  }

  void _openUpcoming(UpcomingItem item) {
    final isBirthday = item.type == UpcomingItemType.birthday;
    _logAction(isBirthday ? 'my_people' : 'life_timeline');
    if (item.sourceId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => isBirthday
              ? PersonDetailScreen(personId: item.sourceId!)
              : LifeEventDetailScreen(eventId: item.sourceId!),
        ),
      );
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(isBirthday ? AppRoutes.savedBirthdays : AppRoutes.lifeTimeline);
  }

  void _openTarget(String target) {
    _logAction(target);
    final route = switch (target) {
      'profile' => AppRoutes.profile,
      'my_people' => AppRoutes.savedBirthdays,
      'life_timeline' => AppRoutes.lifeTimeline,
      'life_calendar' => AppRoutes.lifeCalendar,
      _ => AppRoutes.home,
    };
    Navigator.of(context).pushNamed(route);
  }

  void _logAction(String target) {
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.todayDashboardAction,
          parameters: <String, Object>{'target': target},
        );
  }

  Future<void> _openLink(String rawUrl) async {
    await launchUrl(Uri.parse(rawUrl), mode: LaunchMode.externalApplication);
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.dashboard});

  final TodayDashboardState dashboard;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final name = dashboard.profile?.displayName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dashboard.hasProfile) ...[
          Text(
            'Today',
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            name?.isNotEmpty == true ? name! : 'Your day at a glance',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 28,
              height: 1.12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ] else ...[
          Text(
            AppStrings.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Text(
          dashboard.hasProfile
              ? 'Your age, milestones, and what’s coming up.'
              : 'Age, date, birthday, and time tools',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.onSetBirthday, required this.onCalculateAge});

  final VoidCallback onSetBirthday;
  final VoidCallback onCalculateAge;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    Icons.cake_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Make Age Calculator yours',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Set your birthday once to unlock your personalized dashboard.',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: onSetBirthday,
                icon: const Icon(Icons.cake_outlined, size: 20),
                label: const Text('Set My Birthday'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                ),
              ),
              TextButton(
                onPressed: onCalculateAge,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                child: const Text('Calculate an Age'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonalizedContent extends StatelessWidget {
  const _PersonalizedContent({
    required this.dashboard,
    required this.onProfile,
    required this.onCalculateAge,
    required this.onUpcoming,
    required this.onQuickAction,
  });

  final TodayDashboardState dashboard;
  final VoidCallback onProfile;
  final VoidCallback onCalculateAge;
  final ValueChanged<UpcomingItem> onUpcoming;
  final ValueChanged<String> onQuickAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AgeCard(dashboard: dashboard, onTap: onCalculateAge),
        const SizedBox(height: AppSpacing.md),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _BirthdayCard(dashboard: dashboard)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _MilestoneCard(dashboard: dashboard)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SectionLabel(title: 'Coming Up', icon: Icons.upcoming_outlined),
        const SizedBox(height: AppSpacing.sm),
        if (dashboard.upcoming.isEmpty)
          const AppCard(child: Text('Nothing scheduled yet.'))
        else
          for (final item in dashboard.upcoming) ...[
            _UpcomingCard(item: item, onTap: () => onUpcoming(item)),
            const SizedBox(height: AppSpacing.sm),
          ],
        const SizedBox(height: AppSpacing.md),
        const _SectionLabel(title: 'Quick Actions', icon: Icons.bolt_outlined),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ActionChip(
              label: 'My Profile',
              icon: Icons.person_outline,
              onTap: onProfile,
            ),
            _ActionChip(
              label: 'My People',
              icon: Icons.favorite_outline,
              onTap: () => onQuickAction('my_people'),
            ),
            _ActionChip(
              label: 'Life Timeline',
              icon: Icons.timeline_outlined,
              onTap: () => onQuickAction('life_timeline'),
            ),
            _ActionChip(
              label: 'Life Calendar',
              icon: Icons.grid_view_rounded,
              onTap: () => onQuickAction('life_calendar'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AgeCard extends StatelessWidget {
  const _AgeCard({required this.dashboard, required this.onTap});

  final TodayDashboardState dashboard;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final age = dashboard.age!;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      emphasized: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your age today',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${age.years} ${age.years == 1 ? 'year' : 'years'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 38,
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${age.months} months · ${age.days} days',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${AppDateUtils.formatLargeInteger(age.totalDays)} days lived',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _BirthdayCard extends StatelessWidget {
  const _BirthdayCard({required this.dashboard});

  final TodayDashboardState dashboard;

  @override
  Widget build(BuildContext context) {
    final birthday = dashboard.birthday!;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MetricLabel(icon: Icons.cake_outlined, label: 'NEXT BIRTHDAY'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            birthday.daysUntilNextBirthday == 0
                ? 'Today!'
                : '${birthday.daysUntilNextBirthday} days',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat('EEE, d MMM').format(birthday.nextBirthdayDate),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.dashboard});

  final TodayDashboardState dashboard;

  @override
  Widget build(BuildContext context) {
    final milestone = dashboard.nextMilestone!;
    final daysAway = milestone.date.difference(dashboard.now).inDays;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MetricLabel(
            icon: Icons.flag_outlined,
            label: 'NEXT MILESTONE',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${AppDateUtils.formatLargeInteger(milestone.days)} days',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            daysAway == 0 ? 'Today' : 'in $daysAway days',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.item, required this.onTap});

  final UpcomingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  DateFormat('EEE, d MMM').format(item.targetDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                item.daysRemaining == 0 ? 'Today' : 'in ${item.daysRemaining}d',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icon, size: 18, color: scheme.primary),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: scheme.surfaceContainerHighest,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: Theme.of(context).textTheme.labelLarge,
    );
  }
}

class _MetricLabel extends StatelessWidget {
  const _MetricLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolColors {
  _ToolColors._();

  static const Color age = Color(0xFF0EA5E9);
  static const Color saved = Color(0xFFEC4899);
  static const Color timeline = Color(0xFF06B6D4);
  static const Color calendar = Color(0xFF8B5CF6);
  static const Color dateDiff = Color(0xFF14B8A6);
  static const Color ageDiff = Color(0xFF6366F1);
  static const Color famous = Color(0xFFF59E0B);
  static const Color history = Color(0xFFA855F7);
  static const Color settings = Color(0xFF64748B);
  static const Color about = Color(0xFF0EA5E9);
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.md),
        Text(label),
      ],
    );
  }
}

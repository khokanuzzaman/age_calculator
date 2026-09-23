import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../../shared/widgets/theme_mode_bottom_sheet.dart';
import '../../age_calculator/application/age_calculator_notifier.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  await Share.share(
                    AppStrings.shareAppMessage,
                    subject: AppStrings.appName,
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
                    AppSpacing.base,
                    AppSpacing.base,
                    AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _DashboardHeader(dashboard: dashboard),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: dashboard.hasProfile
                        ? _PersonalizedContent(
                            dashboard: dashboard,
                            onProfile: _openProfile,
                            onCalculateAge: () => _openAgeCalculator(dashboard),
                            onUpcoming: _openUpcoming,
                            onQuickAction: _openTarget,
                          )
                        : _SetupCard(
                            onSetBirthday: _openProfile,
                            onCalculateAge: () => _openAgeCalculator(dashboard),
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.lg,
                      bottom: AppSpacing.sm,
                    ),
                    child: Text(
                      'Tools',
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.huge),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 360,
                          mainAxisExtent: 132,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                        ),
                    delegate: SliverChildListDelegate.fixed([
                      ToolMenuCard(
                        accent: _ToolColors.age,
                        title: 'Calculate Your Age',
                        description:
                            'Exact age, zodiac, milestones & lifetime totals',
                        icon: Icons.cake_outlined,
                        onTap: () => _openAgeCalculator(dashboard),
                      ),
                      _tool(
                        accent: _ToolColors.saved,
                        title: 'My People',
                        description: 'Track the people you love',
                        icon: Icons.favorite_outline,
                        route: AppRoutes.savedBirthdays,
                        target: 'my_people',
                      ),
                      _tool(
                        accent: _ToolColors.timeline,
                        title: 'Life Timeline',
                        description: 'Age at important moments',
                        icon: Icons.timeline_outlined,
                        route: AppRoutes.lifeTimeline,
                      ),
                      _tool(
                        accent: _ToolColors.calendar,
                        title: 'Life Calendar',
                        description: 'See your life in weeks',
                        icon: Icons.grid_view_rounded,
                        route: AppRoutes.lifeCalendar,
                      ),
                      _tool(
                        accent: _ToolColors.dateDiff,
                        title: 'Date Difference',
                        description: 'Gap between dates',
                        icon: Icons.date_range_outlined,
                        route: AppRoutes.dateDifference,
                      ),
                      _tool(
                        accent: _ToolColors.ageDiff,
                        title: 'Age Difference',
                        description: 'Compare two ages',
                        icon: Icons.people_alt_outlined,
                        route: AppRoutes.ageDifference,
                      ),
                      _tool(
                        accent: _ToolColors.leap,
                        title: 'Leap Year',
                        description: 'Check leap years',
                        icon: Icons.event_repeat_outlined,
                        route: AppRoutes.leapYear,
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
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ToolMenuCard _tool({
    required Color accent,
    required String title,
    required String description,
    required IconData icon,
    required String route,
    String? target,
  }) {
    return ToolMenuCard(
      accent: accent,
      title: title,
      description: description,
      icon: icon,
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
    _logAction(
      item.type == UpcomingItemType.birthday ? 'my_people' : 'life_timeline',
    );
    Navigator.of(context).pushNamed(
      item.type == UpcomingItemType.birthday
          ? AppRoutes.savedBirthdays
          : AppRoutes.lifeTimeline,
    );
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
        Text(
          dashboard.hasProfile
              ? name?.isNotEmpty == true
                    ? 'Today, $name'
                    : 'Your day at a glance'
              : AppStrings.appName,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          dashboard.hasProfile
              ? 'Your age, milestones, and what is coming up.'
              : 'Age, date, birthday, and time tools',
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Make Age Calculator yours',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Set your birthday once to unlock your personalized dashboard.',
          ),
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: 'Set My Birthday',
            icon: Icons.cake_outlined,
            onPressed: onSetBirthday,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onCalculateAge,
            child: const Text('Calculate an Age'),
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
        Row(
          children: [
            Expanded(child: _BirthdayCard(dashboard: dashboard)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _MilestoneCard(dashboard: dashboard)),
          ],
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
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your age today',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${age.years} years, ${age.months} months, ${age.days} days',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${AppDateUtils.formatLargeInteger(age.totalDays)} days lived',
            style: Theme.of(context).textTheme.bodyMedium,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cake_outlined),
          const SizedBox(height: AppSpacing.sm),
          Text(
            birthday.daysUntilNextBirthday == 0
                ? 'Happy birthday!'
                : '${birthday.daysUntilNextBirthday} days',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat('EEE, d MMM').format(birthday.nextBirthdayDate),
            style: Theme.of(context).textTheme.bodySmall,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flag_outlined),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppDateUtils.formatLargeInteger(milestone.days),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            daysAway == 0 ? 'Today' : 'in $daysAway days',
            style: Theme.of(context).textTheme.bodySmall,
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
                Text(item.title, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  DateFormat('EEE, d MMM').format(item.targetDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            item.daysRemaining == 0 ? 'Today' : 'in ${item.daysRemaining}d',
            style: Theme.of(context).textTheme.labelLarge,
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
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
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
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
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
  static const Color leap = Color(0xFF22C55E);
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

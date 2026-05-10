import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../../shared/widgets/theme_mode_bottom_sheet.dart';
import '../widgets/tool_menu_card.dart';

enum _HomeMenuAction { theme, privacyPolicy, shareApp, about }

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
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
                  await Share.share(
                    AppStrings.shareAppMessage,
                    subject: AppStrings.appName,
                  );
                  break;
                case _HomeMenuAction.about:
                  if (!context.mounted) {
                    return;
                  }
                  await Navigator.of(context).pushNamed(AppRoutes.about);
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appName,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Age, date, birthday, and time tools',
                          style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: ToolMenuCard(
                      featured: true,
                      accent: _ToolColors.age,
                      title: 'Calculate Your Age',
                      description:
                          'Exact age, zodiac, milestones & lifetime totals',
                      icon: Icons.cake_outlined,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.ageCalculator),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Tools',
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sm),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    0,
                    AppSpacing.base,
                    AppSpacing.huge,
                  ),
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
                        accent: _ToolColors.saved,
                        title: 'Saved Birthdays',
                        description: 'Track loved ones',
                        icon: Icons.favorite_outline,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.savedBirthdays),
                      ),
                      ToolMenuCard(
                        accent: _ToolColors.dateDiff,
                        title: 'Date Difference',
                        description: 'Gap between dates',
                        icon: Icons.date_range_outlined,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.dateDifference),
                      ),
                      ToolMenuCard(
                        accent: _ToolColors.ageDiff,
                        title: 'Age Difference',
                        description: 'Compare two ages',
                        icon: Icons.people_alt_outlined,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.ageDifference),
                      ),
                      ToolMenuCard(
                        accent: _ToolColors.leap,
                        title: 'Leap Year',
                        description: 'Check leap years',
                        icon: Icons.event_repeat_outlined,
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.leapYear),
                      ),
                      ToolMenuCard(
                        accent: _ToolColors.famous,
                        title: 'Famous Birthdays',
                        description: 'Who shares your day',
                        icon: Icons.star_outline,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.famousBirthdays),
                      ),
                      ToolMenuCard(
                        accent: _ToolColors.history,
                        title: 'On This Day',
                        description: 'History by date',
                        icon: Icons.history_outlined,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.onThisDay),
                      ),
                      ToolMenuCard(
                        accent: _ToolColors.settings,
                        title: 'Settings',
                        description: 'Theme & preferences',
                        icon: Icons.settings_outlined,
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.settings),
                      ),
                      ToolMenuCard(
                        accent: _ToolColors.about,
                        title: 'About',
                        description: 'Developer & privacy',
                        icon: Icons.info_outline,
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.about),
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

  Future<void> _openLink(String rawUrl) async {
    final uri = Uri.parse(rawUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Distinct per-tool accents so the home grid is easy to scan at a glance.
/// Hues are picked to read well on both light and dark surfaces.
class _ToolColors {
  _ToolColors._();

  static const Color age = Color(0xFF0EA5E9); // sky
  static const Color saved = Color(0xFFEC4899); // pink
  static const Color dateDiff = Color(0xFF14B8A6); // teal
  static const Color ageDiff = Color(0xFF6366F1); // indigo
  static const Color leap = Color(0xFF22C55E); // green
  static const Color famous = Color(0xFFF59E0B); // amber
  static const Color history = Color(0xFFA855F7); // purple
  static const Color settings = Color(0xFF64748B); // slate
  static const Color about = Color(0xFF0EA5E9); // sky
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme_mode_notifier.dart';
import '../../../../core/ads/ads_provider.dart';
import '../../../../core/ads/interstitial_ad_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_date_field.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/animated_result_card.dart';
import '../../../about/presentation/screens/about_screen.dart';
import '../../../famous_birthdays/provider/famous_birthday_provider.dart';
import '../../application/age_calculator_notifier.dart';
import '../../utils/age_calculation_utils.dart';
import '../../widgets/result_summary_card.dart';
import '../../widgets/result_tabs.dart';

enum _HomeMenuAction { theme, about }

class AgeCalculatorScreen extends ConsumerWidget {
  const AgeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ageCalculatorProvider);
    final notifier = ref.read(ageCalculatorProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);

    ref.listen<AgeCalculatorState>(ageCalculatorProvider, (previous, next) {
      final message = next.errorMessage;
      if (message == null || message == previous?.errorMessage) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          PopupMenuButton<_HomeMenuAction>(
            tooltip: 'More options',
            onSelected: (action) async {
              switch (action) {
                case _HomeMenuAction.theme:
                  await _showThemePicker(context, ref, themeMode);
                case _HomeMenuAction.about:
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AboutScreen(),
                    ),
                  );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.theme,
                child: _OverflowMenuItem(
                  icon: Icons.palette_outlined,
                  label: 'Theme',
                ),
              ),
              PopupMenuItem<_HomeMenuAction>(
                value: _HomeMenuAction.about,
                child: _OverflowMenuItem(
                  icon: Icons.info_outline,
                  label: 'About',
                ),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            const Positioned.fill(child: _BackdropLayer()),
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.result == null) ...[
                      const _IntroHeader(),
                      const SizedBox(height: AppSpacing.base),
                    ],
                    _AnimatedEnter(
                      delay: 0,
                      child: AppDateField(
                        label: 'Date of Birth',
                        value: state.birthDate,
                        onChanged: (date) {
                          _setBirthDate(notifier, date, state.asOfDate);
                        },
                        firstDate: DateTime(1900),
                        helperText: 'Required',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AnimatedEnter(
                      delay: 70,
                      child: AppDateField(
                        label: 'Calculate As Of',
                        value: state.asOfDate,
                        onChanged: notifier.setAsOfDate,
                        firstDate: DateTime(1900),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _AnimatedEnter(
                      delay: 120,
                      child: AppPrimaryButton(
                        label: 'Calculate',
                        icon: Icons.calculate_outlined,
                        onPressed: state.birthDate == null
                            ? null
                            : () async {
                                await HapticFeedback.lightImpact();
                                notifier.calculate();
                                // Respectful interstitial: fires only every Nth
                                // calculation, and always AFTER the result is
                                // already shown — never before it.
                                if (ref.read(ageCalculatorProvider).result !=
                                    null) {
                                  InterstitialAdManager.instance.registerAction(
                                    adsEnabled: ref.read(adsEnabledProvider),
                                  );
                                }
                              },
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: AppDurations.slow,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        key: ValueKey(state.result?.hashCode ?? 'empty-state'),
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        child: state.result == null
                            ? const _EmptyStateCard()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AnimatedResultCard(
                                    delay: const Duration(milliseconds: 40),
                                    child: ResultSummaryCard(
                                      key: ValueKey(
                                        'summary-${state.result.hashCode}',
                                      ),
                                      result: state.result!,
                                      onReset: notifier.reset,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AnimatedResultCard(
                                    delay: const Duration(milliseconds: 140),
                                    child: ResultTabs(
                                      key: ValueKey(
                                        'tabs-${state.result.hashCode}',
                                      ),
                                      monthDay: monthDayFromDate(
                                        state.result!.birthDate,
                                      ),
                                      birthDate: state.result!.birthDate,
                                      stats: AgeCalculationUtils.lifeStats(
                                        state.result!.birthDate,
                                        DateTime.now(),
                                      ),
                                      birthdayDetails:
                                          AgeCalculationUtils.birthdayDetails(
                                            state.result!.birthDate,
                                            DateTime.now(),
                                          ),
                                      milestones:
                                          AgeCalculationUtils.upcomingMilestones(
                                            state.result!.birthDate,
                                            DateTime.now(),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setBirthDate(
    AgeCalculatorNotifier notifier,
    DateTime date,
    DateTime currentAsOfDate,
  ) {
    notifier.setBirthDate(date);
    if (AppDateUtils.isAfterDay(date, currentAsOfDate)) {
      notifier.setAsOfDate(currentAsOfDate);
    }
  }

  Future<void> _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentThemeMode,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              0,
              AppSpacing.base,
              AppSpacing.base,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...ThemeMode.values.map(
                  (mode) => _ThemeModeOption(
                    themeMode: mode,
                    selected: mode == currentThemeMode,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await HapticFeedback.lightImpact();
                      await ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(mode);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedEnter extends StatefulWidget {
  const _AnimatedEnter({required this.child, required this.delay});

  final Widget child;
  final int delay;

  @override
  State<_AnimatedEnter> createState() => _AnimatedEnterState();
}

class _AnimatedEnterState extends State<_AnimatedEnter> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: AppDurations.slow,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        duration: AppDurations.slow,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _BackdropLayer extends StatelessWidget {
  const _BackdropLayer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: Stack(
        children: [
          Container(color: scheme.surface),
          Positioned(
            top: -120,
            right: -80,
            child: _GlowOrb(
              color: scheme.primary.withValues(alpha: 0.12),
              size: 280,
            ),
          ),
          Positioned(
            bottom: -110,
            left: -70,
            child: _GlowOrb(
              color: scheme.secondary.withValues(alpha: 0.09),
              size: 240,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0.05, 1],
        ),
      ),
    );
  }
}

class _OverflowMenuItem extends StatelessWidget {
  const _OverflowMenuItem({required this.icon, required this.label});

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

class _IntroHeader extends StatelessWidget {
  const _IntroHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.calculate_rounded,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick age math', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pick dates and get a full breakdown instantly.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.themeMode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode themeMode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '${themeMode.label} theme',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(themeMode.icon),
        title: Text(themeMode.label),
        trailing: selected
            ? Icon(Icons.check, color: scheme.primary)
            : const SizedBox.shrink(),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Icon(
                Icons.event_available_outlined,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text('Ready when you are', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pick a birth date, choose any reference day, and calculate the full breakdown in one tap.',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

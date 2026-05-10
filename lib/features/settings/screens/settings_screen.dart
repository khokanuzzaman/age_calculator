import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/theme_mode_notifier.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../../shared/widgets/theme_mode_bottom_sheet.dart';
import '../../saved_birthdays/providers/reminders_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final remindersEnabled = ref.watch(remindersEnabledProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Theme and app preferences',
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Appearance', style: textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.palette_outlined),
                          title: const Text('Theme'),
                          subtitle: Text(themeMode.label),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await showThemeModeBottomSheet(
                              context: context,
                              currentThemeMode: themeMode,
                              onSelected: (mode) {
                                ref
                                    .read(themeModeProvider.notifier)
                                    .setThemeMode(mode);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Birthdays', style: textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.notifications_active_outlined),
                          title: const Text('Birthday reminders'),
                          subtitle: const Text(
                            'Get a yearly reminder for saved birthdays',
                          ),
                          value: remindersEnabled,
                          onChanged: (value) async {
                            final result = await ref
                                .read(remindersEnabledProvider.notifier)
                                .setEnabled(value);
                            if (!context.mounted) {
                              return;
                            }
                            if (value && !result) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Notification permission is required for reminders.',
                                    ),
                                  ),
                                );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('App info', style: textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        const _InfoRow(
                          label: 'Version',
                          value: AppStrings.appVersion,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _LinkRow(
                          label: 'Privacy Policy',
                          value: AppStrings.privacyPolicyUrl,
                          onTap: () => _openLink(AppStrings.privacyPolicyUrl),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: TextStyle(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

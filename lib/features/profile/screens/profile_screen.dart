import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../age_calculator/utils/age_calculation_utils.dart';
import '../models/primary_profile.dart';
import '../providers/primary_profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;
  DateTime? _birthDate;
  late bool _editing;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(primaryProfileProvider);
    _birthDate = profile?.birthDate;
    _editing = profile == null;
    _nameController = TextEditingController(text: profile?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(primaryProfileProvider);
    if (profile != null && !_editing) {
      return _buildProfile(context, profile);
    }
    return _buildEditor(context, profile != null);
  }

  Widget _buildEditor(BuildContext context, bool editingExisting) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(editingExisting ? 'Edit Profile' : 'My Profile'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                Text(
                  editingExisting
                      ? 'Update your profile'
                      : 'Set up your profile',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Add your birthday to unlock your personal dashboard, life calendar, milestones and reminders.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Display name (optional)',
                          hintText: 'How should we greet you?',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppDateField(
                        label: 'Date of Birth',
                        value: _birthDate,
                        onChanged: (date) => setState(() => _birthDate = date),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        helperText: 'Required',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  label: 'Save Profile',
                  icon: Icons.check,
                  onPressed: _birthDate == null ? null : _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(BuildContext context, PrimaryProfile profile) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final age = AppDateUtils.calculateAge(profile.birthDate, now);
    final birthday = AgeCalculationUtils.birthdayDetails(
      profile.birthDate,
      now,
    );
    final ageText =
        '${age.years} years, ${age.months} months, ${age.days} days';
    final countdown = birthday.daysUntilNextBirthday == 0
        ? '🎉 Your birthday is today!'
        : '${birthday.daysUntilNextBirthday} days until your next birthday';

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppScreenBackdrop()),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profile.displayName != null) ...[
                        Text(
                          profile.displayName!,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      Text(
                        ageText,
                        style: textTheme.titleLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Born ${DateFormat('d MMMM yyyy').format(profile.birthDate)}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        countdown,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: 'Edit Profile',
                  icon: Icons.edit_outlined,
                  onPressed: () => setState(() => _editing = true),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _confirmClear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear Profile'),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'My People, Life Timeline events, and app settings are kept when you clear your profile.',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final date = _birthDate;
    if (date == null) {
      return;
    }
    await ref
        .read(primaryProfileProvider.notifier)
        .save(birthDate: date, displayName: _nameController.text);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your personal dashboard is ready.')),
    );
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name == AppRoutes.home);
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear profile?'),
        content: const Text(
          'This removes your personal dashboard, reminders and widget birthday. My People and Life Timeline events will stay on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear Profile'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(primaryProfileProvider.notifier).clear();
      if (mounted) {
        setState(() {
          _birthDate = null;
          _nameController.clear();
          _editing = true;
        });
      }
    }
  }
}

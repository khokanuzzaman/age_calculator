import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../models/birthday_reminder_preferences.dart';
import '../models/saved_person.dart';

Future<SavedPerson?> showPersonEditor(
  BuildContext context, {
  SavedPerson? existing,
}) {
  return showModalBottomSheet<SavedPerson>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _PersonEditorSheet(existing: existing),
  );
}

const _emojiChoices = ['🎂', '🎉', '👨', '👩', '👶', '❤️', '🐶', '🐱', '⭐'];
const _relationChoices = [
  'Family',
  'Friend',
  'Partner',
  'Child',
  'Colleague',
  'Pet',
  'Other',
];

class _PersonEditorSheet extends StatefulWidget {
  const _PersonEditorSheet({this.existing});

  final SavedPerson? existing;

  @override
  State<_PersonEditorSheet> createState() => _PersonEditorSheetState();
}

class _PersonEditorSheetState extends State<_PersonEditorSheet> {
  late final TextEditingController _nameController;
  late DateTime? _birthDate;
  late String _emoji;
  late String? _relation;
  late bool _isFavorite;
  late bool _remindersEnabled;
  late Set<int> _leadDays;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _birthDate = existing?.birthDate;
    _emoji = existing?.emoji ?? _emojiChoices.first;
    _relation = existing?.relation;
    _isFavorite = existing?.isFavorite ?? false;
    final preferences =
        existing?.reminderPreferences ?? const BirthdayReminderPreferences();
    _remindersEnabled = preferences.enabled;
    _leadDays = preferences.leadDays.toSet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Please enter a name.');
      return;
    }
    if (_birthDate == null) {
      _showMessage('Please pick a date of birth.');
      return;
    }
    if (_remindersEnabled && _leadDays.isEmpty) {
      _showMessage('Choose at least one birthday reminder.');
      return;
    }

    final id =
        widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    Navigator.of(context).pop(
      SavedPerson(
        id: id,
        name: name,
        birthDate: _birthDate!,
        emoji: _emoji,
        relation: _relation,
        isFavorite: _isFavorite,
        reminderPreferences: BirthdayReminderPreferences(
          enabled: _remindersEnabled,
          leadDays: _leadDays.toList(),
        ).normalized(),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.existing != null;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        0,
        AppSpacing.base,
        AppSpacing.base + viewInsets,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit person' : 'Add a person',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.base),
            Text('Person', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Mom, Alex, Buddy',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _relation,
              decoration: const InputDecoration(
                labelText: 'Relation (optional)',
                prefixIcon: Icon(Icons.people_outline),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Not specified'),
                ),
                for (final relation in _relationChoices)
                  DropdownMenuItem<String>(
                    value: relation,
                    child: Text(relation),
                  ),
              ],
              onChanged: (value) => setState(() => _relation = value),
            ),
            const SizedBox(height: AppSpacing.md),
            AppDateField(
              label: 'Date of birth',
              value: _birthDate,
              lastDate: DateTime.now(),
              onChanged: (date) => setState(() => _birthDate = date),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Icon', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final emoji in _emojiChoices)
                  ChoiceChip(
                    label: Text(emoji, style: const TextStyle(fontSize: 18)),
                    selected: _emoji == emoji,
                    onSelected: (_) => setState(() => _emoji = emoji),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Reminders', style: textTheme.titleMedium),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Birthday reminders'),
              subtitle: const Text('Use the reminder time from Settings'),
              value: _remindersEnabled,
              onChanged: (value) => setState(() => _remindersEnabled = value),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _remindersEnabled
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Remind me:'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final leadDay
                          in BirthdayReminderPreferences.supportedLeadDays)
                        FilterChip(
                          label: Text(_leadLabel(leadDay)),
                          selected: _leadDays.contains(leadDay),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _leadDays.add(leadDay);
                              } else {
                                _leadDays.remove(leadDay);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.star_outline),
              title: const Text('Favorite'),
              value: _isFavorite,
              onChanged: (value) => setState(() => _isFavorite = value),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: isEditing ? 'Save' : 'Add person',
              icon: Icons.check,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  String _leadLabel(int leadDay) {
    return switch (leadDay) {
      30 => '30 days before',
      7 => '7 days before',
      3 => '3 days before',
      1 => '1 day before',
      _ => 'On birthday',
    };
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../models/life_event.dart';
import '../models/life_event_category.dart';
import '../models/life_event_recurrence.dart';
import '../models/life_event_reminder_preferences.dart';

Future<LifeEvent?> showLifeEventEditor(
  BuildContext context, {
  LifeEvent? existing,
  DateTime? birthDate,
}) {
  return showModalBottomSheet<LifeEvent>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) =>
        _LifeEventEditorSheet(existing: existing, birthDate: birthDate),
  );
}

const _emojiChoices = ['⭐', '🎓', '💍', '💼', '✈️', '🏠', '👶', '🎯', '🎉'];

class _LifeEventEditorSheet extends StatefulWidget {
  const _LifeEventEditorSheet({this.existing, this.birthDate});

  final LifeEvent? existing;
  final DateTime? birthDate;

  @override
  State<_LifeEventEditorSheet> createState() => _LifeEventEditorSheetState();
}

class _LifeEventEditorSheetState extends State<_LifeEventEditorSheet> {
  late final TextEditingController _titleController;
  late DateTime? _eventDate;
  late String _emoji;
  late bool _reminderEnabled;
  late LifeEventCategory _category;
  late LifeEventRecurrence _recurrence;
  late Set<int> _leadDays;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _eventDate = widget.existing?.eventDate;
    _category = widget.existing?.category ?? LifeEventCategory.personal;
    _recurrence = widget.existing?.recurrence ?? LifeEventRecurrence.none;
    _emoji = widget.existing?.emoji ?? _category.defaultEmoji;
    _reminderEnabled = widget.existing?.reminderEnabled ?? true;
    _leadDays = {
      ...(widget.existing?.reminderLeadDays ?? const [1, 0]),
    };
    if (_leadDays.isEmpty) {
      _leadDays = {1, 0};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('Please enter an event name.');
      return;
    }
    final eventDate = _eventDate;
    if (eventDate == null) {
      _showMessage('Please pick an event date.');
      return;
    }
    if (widget.birthDate != null && eventDate.isBefore(widget.birthDate!)) {
      _showMessage('Event date cannot be before your date of birth.');
      return;
    }

    final id =
        widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    Navigator.of(context).pop(
      LifeEvent(
        id: id,
        title: title,
        eventDate: eventDate,
        emoji: _emoji,
        category: _category,
        recurrence: _recurrence,
        reminderPreferences: LifeEventReminderPreferences(
          enabled: _reminderEnabled,
          leadDays: _recurrence == LifeEventRecurrence.yearly
              ? _leadDays.toList()
              : const [0],
        ),
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
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final today = DateTime.now();

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
              isEditing ? 'Edit life event' : 'Add a life event',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.base),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Event name',
                hintText: 'e.g. Graduation, First job, Wedding',
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            AppDateField(
              label: 'Event date',
              value: _eventDate,
              firstDate: DateTime(1900),
              lastDate: DateTime(today.year + 200, 12, 31),
              onChanged: (date) => setState(() => _eventDate = date),
            ),
            const SizedBox(height: AppSpacing.base),
            DropdownButtonFormField<LifeEventCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final category in LifeEventCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text('${category.defaultEmoji} ${category.label}'),
                  ),
              ],
              onChanged: (category) {
                if (category == null) {
                  return;
                }
                setState(() {
                  _category = category;
                  if (!_emojiChoices.contains(_emoji)) {
                    _emoji = category.defaultEmoji;
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.base),
            Text('Repeat', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<LifeEventRecurrence>(
              segments: [
                for (final recurrence in LifeEventRecurrence.values)
                  ButtonSegment(
                    value: recurrence,
                    label: Text(recurrence.label),
                  ),
              ],
              selected: {_recurrence},
              onSelectionChanged: (selection) {
                setState(() => _recurrence = selection.first);
              },
              showSelectedIcon: false,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Use Every year for anniversaries and recurring personal dates.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.base),
            Text('Icon', style: textTheme.labelLarge),
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
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remind me on this date'),
              subtitle: const Text('Uses the existing reminders setting'),
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
            ),
            if (_recurrence == LifeEventRecurrence.yearly) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Remind me before this moment', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final lead in const [7, 1, 0])
                    FilterChip(
                      label: Text(
                        lead == 0 ? 'On the day' : '$lead days before',
                      ),
                      selected: _leadDays.contains(lead),
                      onSelected: !_reminderEnabled
                          ? null
                          : (selected) {
                              setState(() {
                                if (selected) {
                                  _leadDays.add(lead);
                                } else if (_leadDays.length > 1) {
                                  _leadDays.remove(lead);
                                }
                              });
                            },
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: isEditing ? 'Save event' : 'Add event',
              icon: Icons.check,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

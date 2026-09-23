import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../models/life_event.dart';

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _eventDate = widget.existing?.eventDate;
    _emoji = widget.existing?.emoji ?? _emojiChoices.first;
    _reminderEnabled = widget.existing?.reminderEnabled ?? true;
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
        reminderEnabled: _reminderEnabled,
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

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../models/saved_person.dart';

/// Shows a bottom sheet to add or edit a saved birthday. Returns the resulting
/// [SavedPerson], or null if the user cancels.
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _birthDate = widget.existing?.birthDate;
    _emoji = widget.existing?.emoji ?? _emojiChoices.first;
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

    final id =
        widget.existing?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();
    Navigator.of(context).pop(
      SavedPerson(id: id, name: name, birthDate: _birthDate!, emoji: _emoji),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Edit birthday' : 'Add a birthday',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.base),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Mom, Alex, Buddy',
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          AppDateField(
            label: 'Date of birth',
            value: _birthDate,
            lastDate: DateTime.now(),
            onChanged: (date) => setState(() => _birthDate = date),
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
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: isEditing ? 'Save' : 'Add birthday',
            icon: Icons.check,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

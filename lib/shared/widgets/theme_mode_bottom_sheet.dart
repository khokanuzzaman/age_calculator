import 'package:flutter/material.dart';

import '../../app/theme/theme_mode_notifier.dart';
import '../../core/constants/app_constants.dart';

Future<void> showThemeModeBottomSheet({
  required BuildContext context,
  required ThemeMode currentThemeMode,
  required ValueChanged<ThemeMode> onSelected,
}) {
  return showModalBottomSheet<void>(
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
              Text('Theme', style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              ...ThemeMode.values.map(
                (mode) => _ThemeModeOption(
                  themeMode: mode,
                  selected: mode == currentThemeMode,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onSelected(mode);
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

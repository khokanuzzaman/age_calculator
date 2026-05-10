import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.helperText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? helperText;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(now.year + 50),
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final formatted = value != null
        ? DateFormat('d MMMM, yyyy').format(value!)
        : 'Tap to select';
    final semanticsLabel = [
      label,
      formatted,
      if (helperText != null) helperText!,
    ].join(', ');

    return Semantics(
      button: true,
      label: semanticsLabel,
      hint: 'Opens a date picker',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.surfaceContainerHigh,
                scheme.tertiaryContainer.withValues(alpha: 0.25),
              ],
            ),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: InkWell(
            onTap: () => _pickDate(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatted,
                          style: textTheme.titleMedium?.copyWith(
                            color: value != null
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
                            fontWeight: value != null
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        if (helperText != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            helperText!,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: scheme.outline),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

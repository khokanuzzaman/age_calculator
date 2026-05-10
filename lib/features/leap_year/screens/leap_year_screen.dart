import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../../shared/widgets/animated_result_card.dart';
import '../utils/leap_year_utils.dart';
import '../widgets/leap_year_result_card.dart';

class LeapYearScreen extends StatefulWidget {
  const LeapYearScreen({super.key});

  @override
  State<LeapYearScreen> createState() => _LeapYearScreenState();
}

class _LeapYearScreenState extends State<LeapYearScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  LeapYearResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _fillYear(int year) {
    setState(() {
      _controller.text = year.toString();
      _result = null;
    });
  }

  void _calculate() {
    final error = LeapYearUtils.validateYear(_controller.text);
    if (error != null) {
      _showMessage(error);
      return;
    }

    final year = int.parse(_controller.text.trim());
    setState(() {
      _result = LeapYearUtils.calculate(year);
    });
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _result = null;
    });
    _focusNode.unfocus();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(title: const Text('Leap Year')),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Stack(
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
                      'Check whether a year is a leap year.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            maxLength: 4,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Year',
                              counterText: '',
                              hintText: 'Enter a year from 1 to 9999',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _QuickActionChip(
                                label: 'Current year',
                                icon: Icons.today_outlined,
                                onTap: () => _fillYear(currentYear),
                              ),
                              _QuickActionChip(
                                label: 'Next year',
                                icon: Icons.arrow_forward_outlined,
                                onTap: () => _fillYear(currentYear + 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppPrimaryButton(
                      label: 'Check',
                      icon: Icons.fact_check_outlined,
                      onPressed: _calculate,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedSwitcher(
                      duration: AppDurations.normal,
                      child: _result == null
                          ? const _EmptyState()
                          : AnimatedResultCard(
                              key: ValueKey(_result.hashCode),
                              child: LeapYearResultCard(result: _result!),
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
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ActionChip(
      avatar: Icon(icon, size: 18, color: scheme.primary),
      label: Text(label, style: textTheme.labelLarge),
      onPressed: onTap,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        'Enter a year to see the leap year result.',
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

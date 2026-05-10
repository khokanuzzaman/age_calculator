import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_screen_backdrop.dart';
import '../../../shared/widgets/animated_result_card.dart';
import '../utils/age_difference_utils.dart';
import '../widgets/age_difference_result_card.dart';

class AgeDifferenceScreen extends StatefulWidget {
  const AgeDifferenceScreen({super.key});

  @override
  State<AgeDifferenceScreen> createState() => _AgeDifferenceScreenState();
}

class _AgeDifferenceScreenState extends State<AgeDifferenceScreen> {
  DateTime? _personOne;
  DateTime? _personTwo;
  AgeDifferenceResult? _result;

  void _calculate() {
    final personOne = _personOne;
    final personTwo = _personTwo;

    if (personOne == null || personTwo == null) {
      _showMessage('Select both dates first.');
      return;
    }

    if (!AgeDifferenceUtils.isValidBirthDate(personOne) ||
        !AgeDifferenceUtils.isValidBirthDate(personTwo)) {
      _showMessage(AgeDifferenceUtils.futureValidationMessage);
      return;
    }

    setState(() {
      _result = AgeDifferenceUtils.calculate(
        personOneBirthDate: personOne,
        personTwoBirthDate: personTwo,
      );
    });
  }

  void _reset() {
    setState(() {
      _personOne = null;
      _personTwo = null;
      _result = null;
    });
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

    return Scaffold(
      appBar: AppBar(title: const Text('Age Difference')),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
                      'Compare two birthdays and see who is older.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    AppDateField(
                      label: 'Person 1 Date of Birth',
                      value: _personOne,
                      onChanged: (date) => setState(() => _personOne = date),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDateField(
                      label: 'Person 2 Date of Birth',
                      value: _personTwo,
                      onChanged: (date) => setState(() => _personTwo = date),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppPrimaryButton(
                      label: 'Calculate',
                      icon: Icons.compare_arrows_outlined,
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
                              child: AgeDifferenceResultCard(result: _result!),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        'Select two birthdays to compare ages.',
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

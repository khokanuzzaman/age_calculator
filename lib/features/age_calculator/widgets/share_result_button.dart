import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../age_calculator/domain/models/age_result.dart';
import '../utils/result_share_service.dart';

class ShareResultButton extends StatelessWidget {
  const ShareResultButton({super.key, required this.result});

  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () async {
        await HapticFeedback.selectionClick();
        if (!context.mounted) {
          return;
        }
        await ResultShareService.shareResult(
          context: context,
          result: result,
        );
      },
      icon: const Icon(Icons.share_outlined),
      label: const Text('Share Result'),
    );
  }
}

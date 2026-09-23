import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Small, theme-independent footer for visual content shared outside the app.
class ShareCardBranding extends StatelessWidget {
  const ShareCardBranding({super.key, this.includePlatformHint = true});

  final bool includePlatformHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          AppStrings.appName,
          style: TextStyle(
            color: Color(0xFFB9C2D0),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (includePlatformHint) ...[
          const SizedBox(height: 2),
          const Text(
            'Available on Android & iPhone',
            style: TextStyle(
              color: Color(0xFF8E9AAD),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

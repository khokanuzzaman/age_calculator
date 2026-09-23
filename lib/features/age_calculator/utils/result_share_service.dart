import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/sharing/app_store_links.dart';
import '../../../core/sharing/share_engine.dart';
import '../../../core/sharing/share_payload.dart';
import '../../../core/sharing/share_result.dart';
import '../../age_calculator/domain/models/age_result.dart';
import '../widgets/shareable_result_card.dart';
import 'age_calculation_utils.dart';

enum ResultShareFormat {
  image('image'),
  textFallback('text_fallback');

  const ResultShareFormat(this.value);

  final String value;
}

/// Captures the [ShareableResultCard] off screen and shares it as a PNG with a
/// text caption. Falls back to plain-text sharing if image capture fails so the
/// user can always share something.
class ResultShareService {
  ResultShareService._();

  static Future<ResultShareFormat> shareResult({
    required BuildContext context,
    required AgeResult result,
  }) async {
    final caption = AgeCalculationUtils.buildShareText(
      years: result.years,
      months: result.months,
      days: result.days,
      totalDays: result.totalDays,
      daysUntilNextBirthday: result.daysUntilNextBirthday,
    );

    final shareResult = await ShareEngine().share(
      context,
      SharePayload(
        text: AppStoreLinks.captionFor(caption, includeStoreLinks: true),
        subject: AppStrings.appName,
        widget: ShareableResultCard(result: result),
        fileName: 'age_result.png',
      ),
    );
    return switch (shareResult) {
      ShareResult.image => ResultShareFormat.image,
      ShareResult.textFallback ||
      ShareResult.text => ResultShareFormat.textFallback,
    };
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
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

    Uint8List? bytes;
    try {
      bytes = await ScreenshotController().captureFromWidget(
        ShareableResultCard(result: result),
        context: context,
        pixelRatio: 3,
        delay: const Duration(milliseconds: 20),
      );
    } catch (_) {
      bytes = null;
    }

    if (bytes == null) {
      await Share.share(caption, subject: AppStrings.appName);
      return ResultShareFormat.textFallback;
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/age_result.png');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: caption,
        subject: AppStrings.appName,
      );
      return ResultShareFormat.image;
    } catch (_) {
      await Share.share(caption, subject: AppStrings.appName);
      return ResultShareFormat.textFallback;
    }
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../models/life_calendar_model.dart';
import '../widgets/life_calendar_share_card.dart';

class LifeCalendarShareService {
  LifeCalendarShareService._();

  static Future<void> shareCalendar({
    required BuildContext context,
    required LifeCalendarSummary summary,
  }) async {
    final caption =
        'My life in weeks\n'
        '${summary.completedWeeks} weeks lived\n'
        '${summary.currentAge.compactText}\n\n'
        'Visualized with ${AppStrings.appName}.';

    Uint8List? bytes;
    try {
      bytes = await ScreenshotController().captureFromWidget(
        LifeCalendarShareCard(summary: summary),
        context: context,
        pixelRatio: 3,
        delay: const Duration(milliseconds: 20),
      );
    } catch (_) {
      bytes = null;
    }

    if (bytes == null) {
      await Share.share(caption, subject: AppStrings.appName);
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/life_calendar.png');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: caption,
        subject: AppStrings.appName,
      );
    } catch (_) {
      await Share.share(caption, subject: AppStrings.appName);
    }
  }
}

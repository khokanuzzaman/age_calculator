import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../models/life_event.dart';
import '../widgets/life_event_share_card.dart';
import 'life_event_utils.dart';

class LifeEventShareService {
  LifeEventShareService._();

  static Future<void> shareEvent({
    required BuildContext context,
    required LifeEvent event,
    required LifeEventDetails details,
  }) async {
    final caption = LifeEventUtils.buildShareText(
      event: event,
      details: details,
    );

    Uint8List? bytes;
    try {
      bytes = await ScreenshotController().captureFromWidget(
        LifeEventShareCard(event: event, details: details),
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
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/life_event.png');
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

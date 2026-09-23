import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/sharing/app_store_links.dart';
import '../../../core/sharing/share_engine.dart';
import '../../../core/sharing/share_payload.dart';
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

    await ShareEngine().share(
      context,
      SharePayload(
        text: AppStoreLinks.captionFor(caption, includeStoreLinks: true),
        subject: AppStrings.appName,
        widget: LifeEventShareCard(event: event, details: details),
        fileName: 'life_event.png',
      ),
    );
  }
}

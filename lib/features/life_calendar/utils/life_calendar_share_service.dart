import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/sharing/app_store_links.dart';
import '../../../core/sharing/share_engine.dart';
import '../../../core/sharing/share_payload.dart';
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

    await ShareEngine().share(
      context,
      SharePayload(
        text: AppStoreLinks.captionFor(caption, includeStoreLinks: true),
        subject: AppStrings.appName,
        widget: LifeCalendarShareCard(summary: summary),
        fileName: 'life_calendar.png',
      ),
    );
  }
}

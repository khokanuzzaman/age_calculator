import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/sharing/app_store_links.dart';
import '../../../core/sharing/share_engine.dart';
import '../../../core/sharing/share_payload.dart';
import '../../../core/sharing/share_result.dart';
import '../../saved_birthdays/models/saved_person.dart';
import '../models/birthday_share_card_model.dart';
import '../widgets/birthday_share_card.dart';

class BirthdayShareService {
  BirthdayShareService({ShareEngine? engine})
    : _engine = engine ?? ShareEngine();

  final ShareEngine _engine;

  Future<ShareResult> shareCard({
    required BuildContext context,
    required SavedPerson person,
    DateTime? now,
  }) {
    final model = BirthdayShareCardModel.fromPerson(
      person,
      now ?? DateTime.now(),
    );
    return _engine.share(
      context,
      SharePayload(
        text: AppStoreLinks.captionFor(
          model.shareText,
          includeStoreLinks: true,
        ),
        subject: AppStrings.appName,
        widget: BirthdayShareCard(model: model),
        fileName: 'birthday_card.png',
      ),
    );
  }
}

import 'package:in_app_review/in_app_review.dart';

abstract interface class ReviewGateway {
  Future<bool> isAvailable();

  Future<void> requestReview();

  Future<void> openStoreListing({String? appStoreId});
}

class InAppReviewGateway implements ReviewGateway {
  InAppReviewGateway({InAppReview? review})
    : _review = review ?? InAppReview.instance;

  final InAppReview _review;

  @override
  Future<bool> isAvailable() => _review.isAvailable();

  @override
  Future<void> requestReview() => _review.requestReview();

  @override
  Future<void> openStoreListing({String? appStoreId}) {
    return _review.openStoreListing(appStoreId: appStoreId);
  }
}

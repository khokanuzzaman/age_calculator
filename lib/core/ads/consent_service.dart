import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';

/// Runs Google's User Messaging Platform (UMP) consent flow before ads are
/// requested, so EEA/UK users see the consent form the privacy policy
/// describes. Every SDK call here is bridged to a [Future] via [Completer];
/// callers are expected to wrap this in their own try/catch (see
/// `main.dart`'s `_initAds`), matching the "ads are non-critical" pattern
/// used throughout `core/ads/`.
class ConsentService {
  ConsentService._();

  static final ConsentService instance = ConsentService._();

  /// Forces EEA debug geography and registers [AdsConfig.testDeviceIds] as
  /// UMP debug devices, so the consent form can be exercised on a test
  /// device without waiting for a genuine EEA/UK IP.
  ///
  /// ⚠️ Must stay `false` in any release build — flip locally to verify the
  /// form, then revert before shipping.
  static const bool kDebugForceEEAConsent = false;

  /// Requests updated consent info and shows the consent form only if
  /// Google determines one is required for this user (typically EEA/UK).
  /// No-ops otherwise.
  Future<void> requestConsentIfNeeded() async {
    final params = ConsentRequestParameters(
      consentDebugSettings: kDebugForceEEAConsent
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: AdsConfig.testDeviceIds,
            )
          : null,
    );

    final updateCompleter = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      updateCompleter.complete,
      (error) => updateCompleter.completeError(error),
    );
    try {
      await updateCompleter.future;
    } catch (error) {
      if (kDebugForceEEAConsent) {
        debugPrint('[UMP] requestConsentInfoUpdate failed: '
            '${_describeError(error)}');
      }
      rethrow;
    }

    final status = await ConsentInformation.instance.getConsentStatus();
    if (kDebugForceEEAConsent) {
      debugPrint('[UMP] getConsentStatus=$status');
    }

    if (!await ConsentInformation.instance.isConsentFormAvailable()) {
      return;
    }
    if (status != ConsentStatus.required) {
      return;
    }

    final formCompleter = Completer<ConsentForm>();
    ConsentForm.loadConsentForm(
      formCompleter.complete,
      (error) => formCompleter.completeError(error),
    );
    final form = await formCompleter.future;

    final showCompleter = Completer<void>();
    form.show((formError) {
      if (formError != null) {
        showCompleter.completeError(formError);
      } else {
        showCompleter.complete();
      }
    });
    await showCompleter.future;
  }

  /// Pure decision: given the SDK's current [canRequestAds] signal, should
  /// ad initialization proceed? Extracted as a static method — called from
  /// `main.dart` — so the gate is also unit-testable without touching the
  /// UMP SDK.
  static bool shouldInitializeAds({required bool canRequestAds}) {
    return canRequestAds;
  }

  /// [FormError]'s default `toString()` is just `Instance of 'FormError'`,
  /// which hides the actual code/message — surface those explicitly so
  /// debug logs are useful.
  static String _describeError(Object error) {
    if (error is FormError) {
      return 'FormError(code: ${error.errorCode}, message: '
          '${error.message})';
    }
    return error.toString();
  }
}

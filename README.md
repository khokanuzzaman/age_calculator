# Age Calculator

Age Calculator is a Flutter app for exact age and date math. It is designed
for Android and iOS and keeps personal inputs on the device.

## Current features

- Exact age calculation with lifetime totals, zodiac, numerology, and milestones
- Date Difference, Age Difference, and Leap Year tools
- Saved birthdays with local yearly reminders
- Famous Birthdays and On This Day results
- Life Timeline and Life Calendar views
- Android home-screen widget for age and birthday/event information
- Light and dark themes, sharing, and privacy/about screens

## Data and connectivity

The calculators, saved birthdays, reminders, and preferences are local and
offline-first. Famous Birthdays and On This Day may make read-only HTTPS
requests to Wikimedia's On This Day endpoint; bundled curated data is used as
a local supplement/fallback. No account or backend is required.

## Ads

The app uses Google Mobile Ads for banner, interstitial, and App Open ads.
AdMob configuration is platform-specific, test devices are configured in
`lib/core/ads/ads_config.dart`, and production builds must use valid app and ad
unit IDs. App Open loading is disabled when its production unit is missing or
malformed.

## Architecture

The code uses a lightweight Clean Architecture layout. Features live under
`lib/features/`; immutable models, repositories, pure date utilities, and
Riverpod notifiers keep business logic out of widgets. Shared platform
services are under `lib/core/`.

Analytics is represented by a vendor-independent no-op abstraction in
`lib/core/analytics/`. Firebase Analytics is planned for a later phase and is
not configured in this repository.

## Run locally

Install Flutter stable, then run:

```sh
flutter pub get
flutter run
```

Use an Android emulator/device or an iOS simulator/device. iOS builds require
the normal Xcode setup and signing configuration.

## Tests

Run static analysis and the test suite with:

```sh
flutter analyze
flutter test
```

## Release/configuration notes

- The installed version shown in Settings/About comes from `package_info_plus`
  and the package/build metadata in `pubspec.yaml`.
- Keep the Android and iOS AdMob app IDs and ad unit IDs separate.
- Review notification permission behavior and store privacy disclosures before
  release.
- Do not add Firebase configuration files until the Firebase integration phase.

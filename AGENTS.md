# AGENTS.md

## Project Overview

**App Name:** Age Calculator
**Package ID / Bundle ID:** `me.khokan.agecalculator` (Android) / `me.khokan.agecalculator.ios` (iOS — suffixed because the unsuffixed string was already registered on the Apple Developer Portal under an account we don't control)
**Platform:** Android + iOS (as of v1.3.0)
**Purpose:** A multi-tool date/age app. Core age calculator (years/months/days/hours/minutes, zodiac, milestones, lifetime totals) plus Date Difference, Age Difference, Leap Year, saved birthdays with reminders, a home-screen widget (Android), Famous Birthdays / On This Day (Wikimedia-backed), and Life Path numerology.
**Primary Goal:** Get approved on Google Play Store and the Apple App Store on the first submission attempt with zero policy violations.

## Owner

- **Developer:** Md Khokanuzzaman Khokan (Khokan)
- **Brand:** Troubleshoot Bangla
- **Portfolio:** https://khokan.me
- **Play Console:** Personal developer account (new, first app)

---

## Core Principles (Non-Negotiable)

These rules override any other instruction. If a request conflicts with these, flag it and stop.

1. **Minimal permissions only.** Currently: `POST_NOTIFICATIONS` + `RECEIVE_BOOT_COMPLETED` (birthday reminders), `AD_ID` (AdMob, Android 13+). No camera, location, storage, contacts, microphone, or SMS. Any *new* dangerous permission needs explicit approval first.
2. **Network access is scoped.** Read-only HTTPS to the Wikimedia On This Day endpoint (month/day only) for Famous Birthdays/On This Day, plus Google Mobile Ads SDK network calls for ad serving. No analytics SDKs, no crash reporting, no other tracking beyond what AdMob itself requires.
3. **Zero user accounts.** No login, no signup, no OAuth, no email collection.
4. **Data collection is limited to ads.** The Play Store Data Safety form / App Store privacy nutrition label must declare exactly what AdMob collects (advertising ID, usage data for ad personalization) and nothing else. No first-party analytics, no first-party tracking.
5. **Zero third-party content.** No copyrighted images, fonts, icons, quotes, or text. Use Google Fonts (Apache 2.0), Material Icons, or original assets only.
6. **English-only UI in v1.** No localization, no language toggle. All user-facing strings in English.
7. **No AI / ML features.** Nothing that would trigger Play's or App Store's generative AI content policy declarations.
8. **AdMob only, no IAP.** Banner/interstitial/app-open ads via `google_mobile_ads`, respectfully frequency-capped (see `AdsConfig`). No other ad networks, no in-app purchases.
9. **Multi-tool, not kitchen-sink.** The app has grown beyond a single calculator into a small suite of date/age tools — that's intentional. New tools should still fit the "age & date math" theme; don't bolt on unrelated features.

---

## Tech Stack

- **Framework:** Flutter (stable channel)
- **Language:** Dart (null-safe, sound null safety required)
- **State Management:** Riverpod (`flutter_riverpod: ^2.5.1`)
- **Local Storage:** `shared_preferences` (theme, saved birthdays, widget data). No SQLite, no Isar, no Hive in v1.
- **Date/Time:** `intl`, `timezone`, `flutter_timezone` for formatting and scheduling
- **Fonts:** `google_fonts: ^6.2.1` (Inter for English UI)
- **Ads:** `google_mobile_ads` (banner/interstitial/app-open, config in `lib/core/ads/`)
- **Notifications:** `flutter_local_notifications` (birthday reminders, requested contextually — never on cold launch)
- **App Tracking Transparency (iOS):** `app_tracking_transparency` (gates personalized ads on iOS 14+)
- **Home-screen widget:** `home_widget` (Android only today — no iOS WidgetKit extension exists yet)
- **Sharing / links:** `share_plus`, `url_launcher`
- **Minimum Android SDK:** 23 (Android 6.0) · **Target:** latest stable (34+)
- **Minimum iOS deployment target:** 15.0

### Forbidden dependencies

Do NOT add any of the following without explicit approval:
- Any analytics package (firebase_analytics, mixpanel, amplitude, etc.) — `google_mobile_ads`'s own telemetry is the one approved exception
- Any additional ad network beyond `google_mobile_ads` (applovin, unity ads, etc.)
- Any crash reporting (firebase_crashlytics, sentry, etc.)
- Any networking package other than `http` for Wikimedia On This Day integration
- Any social login (google_sign_in, facebook_auth, etc.)
- Any in-app purchase package
- WebView packages
- Any package that requires a *new* dangerous `<uses-permission>` on Android or a *new* usage-description key on iOS beyond what's already declared (notifications, ad ID/ATT)

---

## Architecture

Clean Architecture, lightweight version (this is a small app — don't over-engineer).

### Architectural rules

- **No business logic in widgets.** All calculations live in `date_utils.dart` or the notifier.
- **Models are immutable.** Use `final` fields, `const` constructors. No mutation after construction.
- **Notifiers are the only state holders.** Widgets subscribe via `ref.watch` / `ref.read`.
- **Pure functions in `core/utils/`.** No side effects, no platform calls.

---

## Design System

Material 3 Expressive style. Clean, premium, approachable.

### Colors

- **Seed color:** `#6750A4` (Material 3 default purple-indigo) OR a custom seed (Claude will finalize in Phase 1, Prompt 2)
- Generate light & dark schemes via `ColorScheme.fromSeed`
- No hardcoded colors in widgets — always pull from `AppColors` or `Theme.of(context).colorScheme`

### Typography

- **Font:** Inter (via google_fonts)
- **Scale:** Material 3 type scale (displayLarge → labelSmall)
- Defined once in `app_text_styles.dart`, accessed via `Theme.of(context).textTheme`

### Spacing

- 4dp grid: 4, 8, 12, 16, 20, 24, 32, 40, 48
- Constants defined in `app_constants.dart` as `AppSpacing.xs`, `AppSpacing.sm`, etc.

### Components

- **Corner radius:** 16dp for cards, 12dp for buttons, 24dp for large containers
- **Elevation:** Use Material 3 tonal elevation (no hard shadows)
- **Motion:** Default Material 3 easing curves, 200–300ms durations

---

## Feature Spec: Age Calculator v1.3

The hand-maintained per-screen spec below has been retired — it went stale as the app grew (that's exactly what happened to the v1 version of this section). Current features live in `lib/features/`, one directory per tool:

- **Home dashboard** (`home/`) — entry point, links to every tool below
- **Age Calculator** (`age_calculator/`) — DOB + "as of" date, result card with age breakdown, lifetime totals, zodiac, numerology, milestones, share-as-image
- **Saved Birthdays** (`saved_birthdays/`) — track other people's birthdays with yearly reminders
- **Date Difference** / **Age Difference** / **Leap Year** — standalone date-math tools
- **Famous Birthdays** / **On This Day** (`famous_birthdays/`, `on_this_day/`) — Wikimedia-backed, month/day only, with a curated Bangladesh local dataset as fallback/supplement
- **Settings** — theme, reminders toggle
- **About** — app info, developer/brand credit, `url_launcher` link to khokan.me, privacy policy link

When adding a new screen, follow the existing pattern in `lib/features/<name>/` (screens/widgets/providers/utils) rather than writing a new spec section here — keep this file for *rules*, not a screen-by-screen inventory that will drift again.

---

## Workflow

1. User (Khokan) shares a prompt from Claude.
2. Codex executes the prompt exactly as specified.
3. Codex reports back with structured pass/fail for each step.
4. Khokan reviews, runs on emulator, confirms, reports to Claude.
5. Claude sends the next prompt.

### Reporting format (after every prompt)

---

## Code Quality Standards

- **`flutter analyze` must return zero errors** after every prompt. Warnings are acceptable only if intentional and documented.
- **No `print()` statements** in committed code. Use `debugPrint()` during development, remove before release.
- **No TODO comments without a tracking note.** If you must leave a TODO, write `// TODO(khokan): description` so they're greppable.
- **Dart format:** Run `dart format .` before every commit.
- **File naming:** `snake_case.dart`. Class names: `PascalCase`. Variables: `camelCase`.
- **Import order:** dart: → package: → relative imports. Blank line between groups.

---

## Play Store Compliance Checklist (Reference)

Every feature must pass these checks before merging:

- [ ] No dangerous AndroidManifest permissions added
- [ ] Network calls (if any) are limited to Wikimedia On This Day endpoint and send month/day only
- [ ] No third-party SDKs with telemetry
- [ ] No user-generated content (UGC) fields
- [ ] No external links that could lead to policy-violating content
- [ ] No copyrighted assets
- [ ] `flutter analyze` clean
- [ ] APK size delta is reasonable (<2MB per feature)

---

## iOS Platform Notes

- `ios/` was scaffolded via `flutter create --platforms=ios`; bundle ID is `me.khokan.agecalculator.ios` — deliberately *not* matching Android's `me.khokan.agecalculator`, since that exact string was already registered under a different Apple Developer account.
- `Info.plist` carries `GADApplicationIdentifier`, `SKAdNetworkItems` (Google's official 50-entry list), `NSUserTrackingUsageDescription`, and `ITSAppUsesNonExemptEncryption=false`.
- **Before App Store submission:** create a *separate* iOS app entry in the AdMob console (Android's IDs cannot be reused — policy violation) and replace the TODO placeholders in `Info.plist` (`GADApplicationIdentifier`) and `lib/core/ads/ads_config.dart` (`_prodBannerIOS` / `_prodInterstitialIOS` / `_prodAppOpenIOS`). Until then iOS always serves Google's test ads.
- ATT (`app_tracking_transparency`) is requested ~500ms after the first frame, deliberately *after* runApp so it never races the notification-permission dialog (which is now request-on-demand only, not on cold launch — see `NotificationService.init`).
- `home_widget`'s home-screen widget is Android-only. An iOS equivalent needs a WidgetKit extension target (separate Xcode target, App Group, Swift widget code) — not implemented; the Dart service is a safe no-op on iOS.
- Universal app (iPhone + iPad, `TARGETED_DEVICE_FAMILY = "1,2"`); layouts have been spot-checked on both but not exhaustively.

## Out of Scope (v1)

These are explicitly deferred and must NOT be added without discussion:

- Multiple languages
- Themes beyond light/dark
- Backup / export
- iOS WidgetKit home-screen widget (Android widget already ships; see iOS Platform Notes above)

---

## Communication Rules

- When uncertain about scope, **ask before implementing**.
- When a requested change would violate a core principle above, **refuse and flag it**.
- Prefer **small, reviewable changes** over large batches.
- If a prompt is ambiguous, **request clarification** rather than guessing.

---

## Version History

- v0.1 — Initial AGENTS.md (Phase 1 setup)
- v0.2 — Allow Wikimedia month/day-only integration for Famous Birthdays
- v0.3 — Re-baselined for v1.3.0: AdMob ads, notifications, saved birthdays, Android home-screen widget, and iOS platform support are now in scope and shipped. Retired the stale single-screen feature spec in favor of pointing at `lib/features/`.

# AGENTS.md

## Project Overview

**App Name:** Age Calculator
**Package ID:** `me.khokan.agecalculator`
**Platform:** Android only (v1)
**Purpose:** A simple, offline, permission-free age calculator. Calculates exact age in years/months/days/hours/minutes, days until next birthday, and difference between two dates.
**Primary Goal:** Get approved on Google Play Store on the first submission attempt with zero policy violations.

## Owner

- **Developer:** Md Khokanuzzaman Khokan (Khokan)
- **Brand:** Troubleshoot Bangla
- **Portfolio:** https://khokan.me
- **Play Console:** Personal developer account (new, first app)

---

## Core Principles (Non-Negotiable)

These rules override any other instruction. If a request conflicts with these, flag it and stop.

1. **Zero dangerous/runtime permissions.** No camera, location, storage, contacts, microphone, notifications, SMS, phone — nothing. If a feature needs a dangerous permission, reject the feature.
2. **Network access is restricted.** Only read-only HTTPS requests to Wikimedia On This Day endpoint are allowed for the Famous Birthdays feature using month/day only. No analytics, no ads, no crash reporting, and no tracking SDKs.
3. **Zero user accounts.** No login, no signup, no OAuth, no email collection.
4. **Zero data collection.** The Data Safety form on Play Store will declare "No data collected." Every line of code must honor this.
5. **Zero third-party content.** No copyrighted images, fonts, icons, quotes, or text. Use Google Fonts (Apache 2.0), Material Icons, or original assets only.
6. **English-only UI in v1.** No localization, no language toggle. All user-facing strings in English.
7. **No AI / ML features.** Nothing that would trigger Play's generative AI content policy declarations.
8. **No ads, no IAP.** Clean, paid-free v1.
9. **Single purpose.** Age calculation and date math. Nothing else. No "bonus" features.

---

## Tech Stack

- **Framework:** Flutter (stable channel)
- **Language:** Dart (null-safe, sound null safety required)
- **State Management:** Riverpod (`flutter_riverpod: ^2.5.1`)
- **Local Storage:** `shared_preferences` only (for theme preference). No SQLite, no Isar, no Hive in v1.
- **Date/Time:** `intl: ^0.19.0` for formatting
- **Fonts:** `google_fonts: ^6.2.1` (Inter for English UI)
- **Minimum Android SDK:** 23 (Android 6.0)
- **Target Android SDK:** Latest stable (34+)

### Forbidden dependencies

Do NOT add any of the following without explicit approval:
- Any analytics package (firebase_analytics, mixpanel, amplitude, etc.)
- Any ad package (google_mobile_ads, applovin, etc.)
- Any crash reporting (firebase_crashlytics, sentry, etc.)
- Any networking package other than `http` for Wikimedia On This Day integration
- Any permission package (permission_handler, etc.)
- Any social login (google_sign_in, facebook_auth, etc.)
- Any in-app purchase package
- WebView packages
- Any package that requires adding dangerous `<uses-permission>` declarations to AndroidManifest.xml

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

## Feature Spec: Age Calculator v1

### Screen 1: Home Screen
- App bar: "Age Calculator" + theme toggle icon (sun/moon)
- Date of Birth picker (required)
- "Calculate as of" date picker (defaults to today, editable)
- Primary button: "Calculate"
- Result card (appears after calculation):
  - Age in years, months, days (large, prominent)
  - Total days lived
  - Total hours lived
  - Total minutes lived
  - Days until next birthday
  - Day of the week they were born
- "Reset" button below result

### Screen 2: About Screen (accessible via app bar overflow menu)
- App name, version
- Developer: Md Khokanuzzaman Khokan
- Brand: Troubleshoot Bangla
- Link: khokan.me (opens in browser via `url_launcher` — BUT url_launcher is allowed ONLY if it doesn't trigger any permission declaration; verify before adding)
- Privacy policy link
- "Made with Flutter" credit

> **Note on url_launcher:** If adding `url_launcher` requires adding `<queries>` to AndroidManifest, that's acceptable (no runtime permission). Just display the URL as selectable text if in doubt.

### No other screens in v1.

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

## Out of Scope (v1)

These are explicitly deferred and must NOT be added without discussion:

- Notifications / reminders for birthdays
- Saving multiple people's birthdays
- Widgets (home screen widgets)
- Share functionality (can be added in v1.1 if it doesn't complicate review)
- Multiple languages
- Themes beyond light/dark
- Backup / export
- Apple / iOS support

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

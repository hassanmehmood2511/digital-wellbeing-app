# Behtar

Behtar is a Flutter digital wellbeing app focused on building healthier daily
habits through small, manageable steps. The current project is a frontend demo:
challenge and settings data are mock/local state, with no backend or account
service connected.

## Feature status

### Implemented

- **Challenges:** Browse sample 7-day challenges; create a challenge with a
  predefined or custom goal, start date, and public/private visibility; preview
  and save it locally; join or leave with confirmation; and record daily
  progress with completion feedback. Private visibility and invited access are
  represented in local model state only.
- **Profile:** View the sample profile and edit the name and phone number. The
  sign-up email is read-only; profile changes are held in memory.
- **Settings:** Select English or Urdu and toggle notification/reminder
  preferences. These are demo preferences kept in memory; language selection
  does not localize the app and no notification service is connected.
- **Account settings:** View the sample email and open confirmation dialogs for
  sign-out and account deletion. These actions do not change an account or
  delete data.
- **App shell and design system:** Material 3 theme, shared Behtar color,
  typography, spacing and radius tokens, and bottom navigation.

### In Progress (navigation placeholders only)

No active work on these areas is documented in the repository.

- **Home:** Displays a welcome message; no dashboard data or interactions yet.
- **Habits:** Displays a placeholder; habit creation and tracking are not
  implemented.
- **Progress tracking:** Displays a placeholder; there are no charts or
  cross-feature progress summaries.
- **Apps:** Displays a placeholder; app selection or device-usage controls are
  not implemented.

### Planned / not started

The repository includes empty feature directories for `auth`, `onboarding`,
`digital_wellbeing`, and `groups`. They contain no feature implementation or
specification yet. These names and the placeholder destinations are the only
roadmap indicators in the codebase; no separate product roadmap exists. Do not
treat these areas as shipped features.

## Technology

- **Flutter** with **Dart** (`pubspec.yaml` requires Dart `^3.12.0`)
- **Material 3** widgets and a shared theme in `lib/core/theme/app_theme.dart`
- **google_fonts** for Poppins and Inter; **cupertino_icons** for icon assets
- **flutter_test** and **flutter_lints** for tests and static analysis
- Android configuration uses Kotlin DSL, Java 17, Android Gradle Plugin 9.0.1,
  and Kotlin 2.3.20.

Android and Web project scaffolding are present. There is no `ios/` project in
this repository.

## Project structure

```text
lib/
  main.dart
  core/
    routing/       # App navigation shell
    theme/         # Behtar theme and design tokens
    widgets/       # Shared bottom navigation
    constants/     # Empty
    utils/         # Empty
  features/
    challenges/    # Challenge model, controller, and screens
    settings/      # Profile, account, language, and notification settings
    auth/                  # Empty
    digital_wellbeing/     # Empty
    groups/                # Empty
    habits/                # Empty
    home/                  # Empty
    onboarding/            # Empty
test/
  core/            # Navigation widget tests
  features/        # Challenges and settings tests
assets/
  fonts/
  icons/
  images/          # Asset directories currently contain .gitkeep files
android/           # Android host and Gradle configuration
web/               # Flutter Web host files
```

## Requirements

- Flutter SDK with Dart `^3.12.0` support
- Android Studio and an Android SDK/emulator for Android runs and builds
- Chrome for the Web run command below

Check the local toolchain before getting started:

```bash
flutter --version
flutter doctor
```

## Setup and run

From the repository root:

```bash
flutter pub get
flutter run
```

To run in Chrome:

```bash
flutter run -d chrome
```

## Configuration and integrations

- No `.env` file, Dart environment defines, or app-specific environment
  variables are used by the current source.
- No API endpoints, HTTP client, Firebase setup, or backend service is
  configured. Challenge and settings interactions use in-memory demo state;
  state is not persisted across app restarts.
- Android Gradle configuration reads the local Flutter SDK path from
  `android/local.properties`, normally generated/configured by Flutter tooling.
- The Android package ID is currently the template value
  `com.example.digital_wellbeing_app`; update it before publishing.
- Android release builds currently use the debug signing configuration. Set up
  a proper release keystore before distributing a release build.

## Development commands

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
flutter build web
```

`flutter run` and `flutter build` also accept the platform/device options
supported by the installed Flutter SDK.

## Contribution workflow

The repository does not include a `CONTRIBUTING.md` or CI workflow. The
following is a suggested checklist for changes:

1. Create a focused branch from the current project branch.
2. Keep feature changes within the relevant `lib/features/` area and reuse the
   shared theme and widgets.
3. Add or update tests under `test/` for changed behavior.
4. Run `dart format lib test`, `flutter analyze`, and `flutter test`.
5. Open a pull request with a concise summary and test results. The repository's
   `.github/workflow/CODEOWNERS` lists `@JawadZafar1045` and
   `@hassanmehmood2511` as code owners.

## License

No license file is currently present in the repository. Confirm the project's
license before reusing or distributing its code.

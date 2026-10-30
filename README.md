# Behtar

Behtar is a Flutter digital wellbeing app focused on building healthier daily
habits through small, manageable steps. The current project is a frontend demo:
challenge and settings data are mock/local state, with no backend or account
service connected.

## Feature status

The app includes screens for authentication and onboarding, a home dashboard,
habits, challenges, groups, progress/rewards, profile and settings, and digital
wellbeing. These are frontend/demo flows: data is local or in-memory, and no
backend, account service, notification service, or device-usage integration is
configured. See the relevant feature folders for implementation details.

## Technology

- **Flutter** with **Dart** (`pubspec.yaml` requires Dart `^3.12.0`)
- **Material 3** widgets and a shared theme in `lib/core/theme/app_theme.dart`
- **google_fonts** for Poppins and Inter
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
  routing/                   # App navigation shell
  theme/                     # Behtar theme and design tokens
  widgets/                   # Shared bottom navigation
features/
  auth/
    screens/                  # Sign-up, login, and password recovery
    widgets/                  # Shared authentication UI
  challenges/                 # Challenge model, controller, and screens
  digital_wellbeing/
    data/                     # App usage data source
    models/                   # App usage model
    screens/                  # Usage overview, limits, and app settings
  groups/                     # Group models, controller, and screens
  habits/
    data/                     # Habit store and sample data
    models/                   # Habit model
    presentation/             # Habit screens and widgets
  home/
    models/                   # Dashboard preview data
    widgets/                  # Reusable dashboard components
  onboarding_screen/          # Onboarding screens and shared layout
  rewards/                    # Progress and rewards
  settings/                   # Profile, account, language, and notifications
  splashscreen/
test/
  core/                       # Navigation widget tests
  features/                   # Feature tests
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

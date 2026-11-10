# Behtar

Behtar is a Flutter digital wellbeing app that helps people build healthier daily
habits and a calmer relationship with their phone — one small step at a time.

## Features

- **Accounts** — email sign up / login, Google sign-in, password reset by email,
  "remember me", sign out and account deletion (Supabase Auth).
- **Habits** — create habits with targets and priorities, daily check-offs,
  streaks and points.
- **7-day challenges** — public or private challenges, daily progress and a
  completion bonus.
- **Groups** — create a group, invite with a code, shared leaderboard.
- **Progress & rewards** — points history and totals.
- **Screen time (Android)** — real per-app usage from Android "Usage access",
  daily limits, 7-day history, alerts at 80% / 100% of a limit.
- **Notifications** — daily check-in, habit reminders, wellbeing tips and
  screen-time alerts, plus an in-app notification inbox.

## Tech stack

- Flutter / Dart (`pubspec.yaml` requires Dart `>=3.11.0`), Material 3
- Supabase (`supabase_flutter`) for auth and data, with row-level security
- `flutter_local_notifications` + `timezone` for reminders
- Native Android (Kotlin) bridge for screen time in `MainActivity.kt`
- `google_fonts` (Poppins), `shared_preferences`, `intl`

## Getting started

```bash
flutter pub get
flutter run            # Android phone or emulator (full feature set)
flutter run -d chrome  # Web (no screen time or notifications)
```

Database setup (tables, security rules, functions) and Supabase dashboard
settings are described in [SUPABASE_SETUP.md](SUPABASE_SETUP.md). Migrations live
in `supabase/migrations` and are applied with:

```bash
npx supabase db push --remote
```

## Project structure

```text
lib/
  main.dart                      # App start-up, auth flow and routing
  core/
    backend/backend.dart         # Supabase client, error messages, ids
    notifications/               # Local notifications + notification inbox
    routing/                     # Bottom-navigation shell
    theme/                       # Colours, spacing, typography, Material theme
    utils/date_formatters.dart   # Shared date / duration helpers
    widgets/                     # Shared widgets (progress bar, bottom nav)
  features/
    auth/                        # Login, sign up, forgot / reset password
    onboarding_screen/           # First-launch onboarding
    splashscreen/                # Animated splash
    home/                        # Dashboard
    habits/                      # Habit store, models and screens
    challenges/                  # 7-day challenges
    groups/                      # Groups and leaderboard
    rewards/                     # Points and progress
    digital_wellbeing/           # Screen time, limits, usage access
    notifications/               # Notification inbox screen
    settings/                    # Profile, settings, notification preferences
supabase/migrations/             # Database schema and security
test/                            # Unit and widget tests
```

## Testing

```bash
flutter analyze
flutter test
```

Widget tests run without Supabase: stores fall back to in-memory data when no
backend is connected.

# Behtar — Supabase setup

The app code is already connected to your project
(`https://rubhqtlgalqkaiuojrtc.supabase.co`). These one-time steps create the
database and switch on sign-in. Total time: about 10 minutes.

---

## 1. Create the database (required)

**Option A — Dashboard (easiest)**

1. Open your project at https://supabase.com/dashboard → **SQL Editor** → **New query**.
2. Open `supabase/migrations/20261110000000_behtar_schema.sql` from this project,
   copy everything, paste it, and press **Run**.
3. You should see “Success. No rows returned”. In **Table Editor** you will now see:
   `profiles, habits, habit_logs, challenges, challenge_participants, groups,
   group_members, reward_transactions, tracked_apps, app_usage_daily`.

**Option B — Supabase CLI** (if you already installed it)

```bash
supabase login
supabase link --project-ref rubhqtlgalqkaiuojrtc
supabase db push
```

The script is safe to run more than once.

## 2. Allow the app's deep link (required)

Email confirmation, password reset and Google sign-in all return to the app
through `behtar://login-callback`.

**Authentication → URL Configuration → Redirect URLs → Add URL:**

```
behtar://login-callback
```

## 3. Email sign-in settings

**Authentication → Sign In / Providers → Email** (enabled by default).

- **Confirm email ON** (recommended): after sign up the user gets an email,
  taps the link on their phone, and the app opens signed in.
- **Confirm email OFF**: sign up logs the user straight in. Handy while testing.

The built-in Supabase email service only sends a few emails per hour. Before
real users, add your own SMTP under **Authentication → Emails → SMTP Settings**
(e.g. Resend, Brevo, or your technestnova.com mailbox).

## 4. Google sign-in (optional)

The **Continue with Google** button works once Google is enabled:

1. In Google Cloud Console → **APIs & Services → Credentials → Create
   credentials → OAuth client ID → Web application**.
2. Under *Authorized redirect URIs* add:
   `https://rubhqtlgalqkaiuojrtc.supabase.co/auth/v1/callback`
3. Copy the **Client ID** and **Client secret**.
4. In Supabase → **Authentication → Sign In / Providers → Google** → enable,
   paste both values, save.

Until this is done, the button opens a Supabase error page instead.

## 5. Run the app

```bash
flutter pub get
flutter run
```

---

## What is stored where

| Feature | Tables / functions |
| --- | --- |
| Account & profile, language, notification settings | `auth.users`, `profiles` (auto-created on sign up) |
| Habits, daily completions, streaks | `habits`, `habit_logs` |
| 7-day challenges, joining, daily progress | `challenges`, `challenge_participants` |
| Groups, invite codes, leaderboards | `groups`, `group_members`, `join_group_with_code()`, `get_my_group_members()` |
| Points & history | `reward_transactions` |
| Tracked apps, limits, usage history | `tracked_apps`, `app_usage_daily` |
| Delete account | `delete_my_account()` |

Row Level Security is on for every table: each user can only read and change
their own data. Public challenges are visible to everyone signed in; groups are
visible only to their members.

## Quick test checklist

1. Sign up → confirm email (if on) → Home opens with your name.
2. Add a habit, tick it to its target → +10 points, streak 1.
3. Create and join a challenge, log a day → shows on Home.
4. Create a group → copy the invite code → join it from a second account →
   both appear on the leaderboard with their points.
5. Change a limit on the Apps screen, restart the app → it is still there.
6. Profile → Account settings → Sign out → login screen. Log back in → data is back.
7. Forgot password → email link → set a new password → Home.

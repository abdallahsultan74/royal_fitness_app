# Royal Fitness (Mobile App)

Royal Fitness is a Flutter mobile application with a premium “royal” UI, bilingual experience (English / Arabic), and a Supabase-powered backend.

This repository is the **mobile app**. The **admin dashboard** lives in a separate project:
- `../royal_fitness_admin`

## Admin dashboard (separate project)

The admin project is a Vite + React app that connects to the same Supabase backend.

Quick start:

```bash
cd ../royal_fitness_admin
npm install
cp .env.example .env
npx vite
```

For more details (Supabase migrations, deployment), see:
- `../royal_fitness_admin/README.md`

## What this app includes

- Authentication (email/password + email OTP reset flow)
- Onboarding with goal selection and language choice
- Workouts library (Supabase RPC first, local ExerciseDB sample as fallback)
- Guided workout sessions (timer + optional TTS/audio)
- Progress tracking (weight, stats, charts)
- Challenges and active plan (“My Plan”)
- Notifications and staff messaging (inbox/sent + realtime)
- Subscription request flow with a confirmation step (price + coach selection)
- AdMob banner integration (test IDs by default)

## Tech stack

- Flutter / Dart
- `flutter_bloc`, `get_it`, `injectable`
- Supabase (`supabase_flutter`) for auth, database, RPC, and realtime
- `easy_localization` for i18n (EN/AR)
- `fl_chart` for charts
- `google_mobile_ads` for ads

## Project structure

```text
lib/
  main.dart
  app.dart
  core/
  features/
assets/
  translations/
  branding/
  exercisedb_v1_sample/
supabase/
  migrations/
  seed.sql
```

## Configuration

### Supabase

Update the values in:
- `lib/core/backend/supabase_config.dart`

If you use password reset deep links, ensure the redirect URL is whitelisted:
- Supabase Dashboard → Authentication → URL Configuration → Redirect URLs

### RapidAPI (optional)

If you want remote exercise loading via RapidAPI, run with:

```bash
flutter run --dart-define=RAPIDAPI_KEY=your_key
```

If the API is unavailable, the app falls back to local JSON assets.

## Run locally

```bash
flutter pub get
flutter run
```

If generated files are out of sync:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Quality

```bash
flutter analyze
flutter test
```

## Release builds (Android)

Recommended for Play Store:

```bash
flutter build appbundle --release --tree-shake-icons --obfuscate --split-debug-info=build/symbols
```

Smaller APKs for manual distribution/testing:

```bash
flutter build apk --release --split-per-abi --tree-shake-icons --obfuscate --split-debug-info=build/symbols
```

## Notes

- Do not ship `service_role` keys in the mobile app. Use Edge Functions for privileged actions.

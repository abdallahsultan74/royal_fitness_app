# Delivery Checklist (Royal Fitness)

This document is a lightweight handover checklist for **both projects**:

- Mobile app: `royal_fitness_app/` (Flutter)
- Admin dashboard: `royal_fitness_admin/` (React + Vite)

It is written for a developer receiving the codebase for the first time.

---

## 1) What you are receiving

### Mobile app (Flutter)

- Bilingual UI (English/Arabic) via `easy_localization`
- Supabase-backed auth + database + RPC + realtime
- Workouts (RPC-first with local ExerciseDB fallback)
- Progress tracking, challenges, plans
- Notifications/inbox + staff messaging
- Subscription request flow with a confirmation screen (price + coach selection)
- AdMob banner integration (Google **test** unit IDs by default)

Primary docs:

- `royal_fitness_app/README.md`

### Admin dashboard (React + Vite)

- Bilingual UI (English/Arabic)
- Staff-only access (admin + coach roles)
- Dashboard metrics backed by Supabase RPCs
- User management (including delete flows)
- Subscription request management + staff-defined subscription pricing
- Analytics page with charts and exports

Primary docs:

- `royal_fitness_admin/README.md`
- `royal_fitness_admin/SUPABASE_SETUP.md`

---

## 2) Environment prerequisites

### Mobile (Flutter)

- Flutter SDK installed and available in PATH
- Android Studio + SDK tools (for Android builds)
- Xcode (macOS only, for iOS builds)

### Admin (Web)

- Node.js 18+ (recommended)
- npm

---

## 3) Supabase setup (shared backend)

Both the mobile app and admin dashboard are intended to point to the **same Supabase project**.

Database migrations and seed:

- `royal_fitness_app/supabase/migrations/`
- `royal_fitness_app/supabase/seed.sql`
- `royal_fitness_admin/supabase/migrations/` (migration history aligned)

Setup instructions:

- `royal_fitness_admin/SUPABASE_SETUP.md`

Important security rule:

- Never ship `service_role` keys in the mobile app or web admin. Use Edge Functions for privileged operations.

---

## 4) Run locally (quick start)

### Mobile app

From `royal_fitness_app/`:

```bash
flutter pub get
flutter run
```

Optional (RapidAPI):

```bash
flutter run --dart-define=RAPIDAPI_KEY=your_key
```

### Admin dashboard

From `royal_fitness_admin/`:

```bash
npm install
cp .env.example .env
npx vite
```

Required `.env` values for live mode:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

---

## 5) Quality checks

### Mobile app

```bash
flutter analyze
flutter test
```

### Admin dashboard

```bash
npm run build
```

---

## 6) Release artifacts (Android)

These are the standard outputs you should deliver to stakeholders (or upload to Play Console).

### Play Store (recommended)

Build command:

```bash
flutter build appbundle --release --dart-define=CLIENT_DELIVERY=true --tree-shake-icons --obfuscate --split-debug-info=build/symbols
```

Output:

- `royal_fitness_app/build/app/outputs/bundle/release/app-release.aab`

### Manual testing/distribution (smaller APKs)

Build command:

```bash
flutter build apk --release --dart-define=CLIENT_DELIVERY=true --split-per-abi --tree-shake-icons --obfuscate --split-debug-info=build/symbols
```

Outputs:

- `royal_fitness_app/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `royal_fitness_app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `royal_fitness_app/build/app/outputs/flutter-apk/app-x86_64-release.apk`

Debug symbols (for de-obfuscation / crash reporting):

- `royal_fitness_app/build/symbols/`

---

## 7) Deployment (admin dashboard)

### Vercel (typical)

- Create a Vercel project pointing to `royal_fitness_admin/`
- Set environment variables:
  - `VITE_SUPABASE_URL`
  - `VITE_SUPABASE_ANON_KEY`
- Build command: `npm run build`
- Output directory: `dist`

### GitHub Pages (optional)

See `royal_fitness_admin/README.md`.

---

## 8) Final handover checklist

- Supabase project is accessible (credentials + dashboard access)
- `.env` for admin is set and verified in live mode
- Mobile app Supabase config verified in `lib/core/backend/supabase_config.dart`
- Android signing keys configured for release distribution (not debug signing)
- `app-release.aab` generated and stored in a shared delivery folder
- ABI-split APK generated for quick QA installs (optional)
- Debug symbols archived (`build/symbols/`)


# Royal Fitness App

Royal Fitness is a Flutter-based fitness application with a premium “royal” UI, multilingual support (English/Arabic), Supabase-powered backend integration, and modular feature-driven architecture.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Core Features](#core-features)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Backend & Integrations](#backend--integrations)
- [Environment & Configuration](#environment--configuration)
- [Getting Started](#getting-started)
- [Run the App](#run-the-app)
- [Quality & Testing](#quality--testing)
- [Troubleshooting](#troubleshooting)

---

## Project Overview

Royal Fitness focuses on guided workouts, progress tracking, challenge participation, account management, and in-app communication.  
The app uses Supabase as the primary backend for authentication, profile data, workout and challenge data, real-time updates, and messaging.

---

## Core Features

### 1) Authentication & Account Flows
- Email/password login and signup
- Password recovery using email OTP flow
- Password update support inside recovery session
- Session-based app entry gate (onboarding -> auth -> main shell)

### 2) Onboarding
- First-launch onboarding flow with goal selection
- Local onboarding completion state using `SharedPreferences`
- Language selection during onboarding

### 3) Multilingual Experience (EN/AR)
- Localization implemented with `easy_localization`
- Translation assets under `assets/translations/`
- Runtime locale switching from onboarding and settings

### 4) Workout Experience
- Workout library with search and filtering
- Data loading strategy:
  - Primary: Supabase RPC (`api_list_exercises`)
  - Fallback: local ExerciseDB sample JSON assets
- Active workout screen with:
  - Timer-based guided session
  - Voice coach using Text-to-Speech (`flutter_tts`)
  - Optional audio guide playback (`just_audio`)
  - Session persistence and completion tracking

### 5) Progress Tracking
- Weight logging and history visualization
- Workout stats (calories, sessions, completed exercises)
- Charts and trends using `fl_chart`
- Active challenge progress tracking
- Weekly weight reminder behavior

### 6) Challenges & Plans
- Challenge templates retrieval
- Start challenge and complete challenge day via Supabase RPC
- Active challenge stream updates
- “My Plan” retrieval from backend (`api_my_active_plan`)

### 7) Profile & Settings
- Profile read/update from Supabase `profiles`
- Account preference controls (language, toggles)
- Password update entry points
- Entry to notifications/messages area

### 8) Notifications & Messaging
- Inbox and sent messages using real-time streams
- Compose message to admin/coach recipients
- Mark notifications as read

---

## Technology Stack

### Framework & Language
- Flutter
- Dart (SDK constraint in `pubspec.yaml`: `^3.9.2`)

### State Management & DI
- `flutter_bloc`
- `get_it`
- `injectable` (+ generated `injection_container.config.dart`)

### Networking & Data
- `supabase_flutter` (auth, database, RPC, realtime)
- `dio` (RapidAPI client setup for exercise data flow)
- `hive` / `hive_flutter` (local storage initialization)
- `shared_preferences`

### UI & UX
- `easy_localization`
- `google_fonts`
- `flutter_svg`
- `cached_network_image`
- `shimmer`
- `fl_chart`
- `flutter_tts`
- `just_audio`

### Firebase (Repository Artifacts Present)
- `firebase.json` and `firestore.rules` exist in the repository
- Main runtime flow currently initializes and relies on Supabase in `main.dart`

---

## Architecture

The app follows a modular, feature-first architecture with clear separation of concerns:

- `core/`: shared app-wide layers (theme, DI, network, constants, widgets, utilities)
- `features/`: domain modules (auth, workout, progress, profile, challenges, etc.)
- Data-oriented classes (repositories) encapsulate Supabase/RPC/database access
- UI is organized per feature under `presentation/`
- Domain models/entities are kept under `domain/`

Navigation entry:
- `main.dart` initializes dependencies (Hive, Supabase, localization, DI)
- `app.dart` gates onboarding/auth/session and opens `MainShell`
- `MainShell` provides bottom-tab navigation for major modules

---

## Project Structure

```text
royal_fitness_app/
├─ lib/
│  ├─ main.dart
│  ├─ app.dart
│  ├─ core/
│  │  ├─ backend/                # Supabase config
│  │  ├─ constants/              # API constants (RapidAPI key define)
│  │  ├─ di/                     # GetIt + Injectable setup
│  │  ├─ network/                # Dio client
│  │  ├─ theme/                  # app theme and colors
│  │  ├─ common_widgets/         # shared visual components
│  │  └─ ...
│  └─ features/
│     ├─ auth/
│     ├─ onboarding/
│     ├─ shell/
│     ├─ home/
│     ├─ workout/
│     ├─ progress/
│     ├─ challenges/
│     ├─ plans/
│     ├─ profile/
│     └─ notifications/
├─ assets/
│  ├─ translations/              # en.json, ar.json
│  ├─ svg/
│  └─ exercisedb_v1_sample/      # local workouts fallback data + gifs
├─ test/
│  └─ widget_test.dart
├─ firebase.json
├─ firestore.rules
└─ pubspec.yaml
```

---

## Backend & Integrations

### 1) Supabase (Primary Backend)

Configured in:
- `lib/core/backend/supabase_config.dart`
- initialized in `lib/main.dart`

Used for:
- Auth (login, signup, OTP reset, session)
- Database tables (profiles, workouts, progress, notifications, etc.)
- RPC functions (examples used in code):
  - `api_list_exercises`
  - `api_challenge_details`
  - `api_my_active_challenge`
  - `api_my_active_plan`
  - `start_user_challenge`
  - `complete_user_challenge_day`
  - `list_staff_recipients`
- Realtime updates via Postgres change channels

### 2) Exercise Data / RapidAPI

`DioClient` is configured to use ExerciseDB on RapidAPI.  
API key is provided via build-time define:

`--dart-define=RAPIDAPI_KEY=your_key`

If remote exercise loading is unavailable, workout library falls back to local JSON assets.

### 3) Firebase Files

Repository includes Firebase/Firestore configuration artifacts (`firebase.json`, `firestore.rules`).  
The current Flutter runtime entry (`main.dart`) initializes Supabase only and does not initialize Firebase services.

---

## Environment & Configuration

### Required tools
- Flutter SDK installed and available in PATH
- Dart SDK (bundled with Flutter)

### Important runtime config

1. **Supabase**
   - Update values in `lib/core/backend/supabase_config.dart` if needed:
     - `url`
     - `anonKey`
     - `passwordResetRedirectUrl`

2. **Password reset deep link**
   - Add `passwordResetRedirectUrl` to Supabase Auth redirect allow-list:
     - Supabase Dashboard -> Authentication -> URL Configuration -> Redirect URLs

3. **RapidAPI key (optional but recommended for remote exercise API)**
   - Use `RAPIDAPI_KEY` via `--dart-define`

---

## Getting Started

From the repository root:

```bash
flutter pub get
```

If generated files are ever out of sync:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Run the App

### Standard run

```bash
flutter run
```

### Run with RapidAPI key

```bash
flutter run --dart-define=RAPIDAPI_KEY=your_key
```

---

## Quality & Testing

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Current test suite includes widget-level localization/auth gate coverage in `test/widget_test.dart`.

---

## Troubleshooting

- `flutter: command not found`
  - Install Flutter SDK and ensure it is in your PATH.

- Supabase auth or data not working
  - Verify `SupabaseConfig` values.
  - Verify database schema, RPC functions, and RLS policies.
  - Confirm redirect URL is whitelisted in Supabase Auth settings.

- Workout library is empty from backend
  - Confirm `api_list_exercises` RPC and permissions.
  - App should fallback to local JSON assets if API loading fails.

- RapidAPI errors
  - Provide a valid `RAPIDAPI_KEY` via `--dart-define`.

# Activity 8 — Flutter Web Project Initialization

**Subject:** IT 110 — Web Systems and Technologies
**Lesson:** Lesson 8: Flutter Web Project Initialization
**Instructor:** JEAN VILLASIN, MIT

Short description: Clean Flutter Web baseline with Home / Login / Dashboard navigation shell. This is the first working client-side flow before API/database integration.

## Group Members and Roles

| Name | Role |
|------|------|
| andymarkcrasco | Developer / Documentation / UI / Testing |

Checkpoint date: October 2026

## Technology Stack Used

- Flutter 3.47.1 + Dart 3.13.1
- Material 3 (MaterialApp.router)
- Packages:
  - `go_router: ^18.1.0` — declarative navigation shell (Home <-> Login <-> Dashboard). Chosen to keep routes organized in `lib/routes/`.
  - `http: ^1.6.0` — reserved for future API calls (currently only referenced in `AuthService` as readiness proof; login is still local-only).
  - `cupertino_icons` — default icons (from `flutter create`).
- Target: Chrome / Edge (web-javascript)
- Version control: Git + GitHub

## Project Structure

```text
activity8/
├─ lib/
│  ├─ main.dart            # entry point -> runApp(Activity8App)
│  ├─ app.dart             # MaterialApp.router + theme
│  ├─ screens/
│  │  ├─ home_screen.dart      # visible home page
│  │  ├─ login_screen.dart     # login + local validation
│  │  └─ dashboard_screen.dart # module placeholder
│  ├─ widgets/
│  │  ├─ app_shell.dart        # AppBar + top nav + Drawer (navigation shell)
│  │  ├─ app_button.dart       # reusable button
│  │  ├─ app_text_field.dart   # reusable text field
│  │  └─ app_card.dart         # reusable card
│  ├─ routes/
│  │  └─ app_routes.dart       # go_router config (/, /login, /dashboard)
│  ├─ services/
│  │  └─ auth_service.dart     # local-only login, http reserved for later
│  ├─ models/
│  │  └─ user_model.dart       # User data object
│  └─ constants/
│     └─ app_constants.dart    # titles, routes, shared strings
├─ web/                    # web bootstrap assets (do not delete)
├─ test/widget_test.dart   # smoke test: app boots with Home shell
├─ pubspec.yaml            # declares packages
└─ README.md
```

Why this helps: `screens/` holds full pages, `widgets/` holds reusable UI, `services/` will handle API calls, `models/` will represent data, `routes/` keeps navigation organized, `constants/` keeps repeated values in one place.

## How to Run the Flutter Web Project

```bash
# 1. Get packages
flutter pub get

# 2. Check environment (browser device must appear)
flutter doctor
flutter devices

# 3. Run in browser
flutter run -d chrome

# 4. Build for web (output to build/web)
flutter build web
```

Demo login (local only, no backend yet):

- Username: `student`
- Password: `1234`
- Flow: User clicks Login -> validation checks fields -> message / dashboard displays.

## Initial Pages/Screens Included

- [x] Home Page — visible landing with project info + route buttons
- [x] Login Page — form + validation (`AppTextField` + `AppButton`), local `AuthService`
- [x] Navigation Shell — AppBar + top nav buttons + Drawer, consistent theme
- [x] Dashboard / Module Placeholder — proves page transition works

## Repository Link and First Checkpoint

```bash
git init
git add .
git commit -m "Initial Flutter Web project - home/login/navigation shell"
git remote add origin <REMOTE-URL>
git branch -M main
git push -u origin main
```

> TODO: ilisi ang `<REMOTE-URL>` sa imong GitHub repo link, then push.

- GitHub repo: _TODO: paste link here_
- Initial commit: `Initial Flutter Web project - home/login/navigation shell`

## Package Flow (Lesson 8, Slide 11)

Find Package (pub.dev) -> `flutter pub add go_router` / `flutter pub add http` -> `import in Dart` -> `Use in Code` -> `flutter pub get` -> test in browser -> commit after testing.

## How This Grows Into the Proposed System

This initialized project is the Sprint 1 / first increment baseline: clean setup + version control + working shell. Next increments add real modules, REST API (`http`) integration, database, and role-based pages without restructuring folders.

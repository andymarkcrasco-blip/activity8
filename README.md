# Activity 8/9 — Flutter Web Project Initialization & Reusable Screens, Widgets, Async UI States

**Subject:** IT 110 — Web Systems and Technologies
**Lesson:** Lesson 8: Flutter Web Project Initialization
**Activity:** Laboratory Activity No. 9 — Reusable Screen and Widget Structure | Loading, Success, Empty, and Error States
**Instructor:** JEAN VILLASIN, MIT

Short description: Clean Flutter Web baseline (Home / Login / Dashboard navigation shell) extended in Activity 9 with `report_form_screen.dart`, reusable widgets, and four working asynchronous UI state responses for the **EventVenue Caraga** system.

## Group Members and Roles

| Name | Role |
|------|------|
| andymarkcrasco | Developer / Documentation / UI / Testing |

Checkpoint dates: Activity 8 — October 2026 · Activity 9 — October 2026

## Technology Stack Used

- Flutter 3.47.1 + Dart 3.13.1
- Material 3 (`MaterialApp.router`) + `go_router` navigation shell
- Packages:
  - `go_router: ^18.1.0` — declarative navigation (Home <-> Login <-> Dashboard <-> Report Form). Chosen to keep routes organized in `lib/routes/`.
  - `http: ^1.6.0` — reserved for future API calls (the real REST API / PostgreSQL is not connected yet; all responses in Activity 9 are simulated and labeled as such).
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
│  │  ├─ home_screen.dart      # visible home page + "Go to Report Form"
│  │  ├─ login_screen.dart     # login + local validation (Activity 8)
│  │  ├─ dashboard_screen.dart # module placeholder (Activity 8)
│  │  └─ report_form_screen.dart  # NEW in Activity 9: form + 4 async UI states
│  ├─ widgets/
│  │  ├─ app_shell.dart        # AppBar + top nav + Drawer (navigation shell)
│  │  ├─ app_button.dart       # reusable button (+ isLoading state)
│  │  ├─ app_text_field.dart   # reusable input (+ maxLines)
│  │  ├─ app_card.dart         # reusable card
│  │  └─ app_state_view.dart   # NEW in Activity 9: reusable state renderer
│  ├─ routes/
│  │  └─ app_routes.dart       # go_router config (/, /login, /dashboard, /report)
│  ├─ services/
│  │  ├─ auth_service.dart     # local-only login (Activity 8)
│  │  └─ report_service.dart   # NEW in Activity 9: simulated async submit
│  ├─ models/
│  │  ├─ user_model.dart       # User data object (Activity 8)
│  │  └─ report_model.dart     # NEW in Activity 9: Report data object
│  └─ constants/
│     └─ app_constants.dart    # titles, routes, categories, locations
├─ web/                    # web bootstrap assets (do not delete)
├─ test/widget_test.dart   # 6 automated tests incl. the 4 UI states
├─ screenshots/            # Activity 9 evidence screenshots
├─ ACTIVITY9_EVIDENCE_REPORT.docx / .pdf
├─ pubspec.yaml            # declares packages
└─ README.md
```

Why this helps: `screens/` holds full pages, `widgets/` holds reusable UI, `services/` handles (simulated) calls, `models/` represents data, `routes/` keeps navigation organized, `constants/` keeps repeated values in one place.

## Activity 9 — What Was Added

| File | Status | Purpose |
|------|--------|---------|
| `lib/screens/report_form_screen.dart` | **NEW** | Report form for EventVenue Caraga: fields, validation, and the four async UI states |
| `lib/widgets/app_state_view.dart` | **NEW** | Reusable renderer for LOADING / SUCCESS / EMPTY / ERROR responses |
| `lib/services/report_service.dart` | **NEW** | Simulated async submit (`Future.delayed`), can simulate a server failure |
| `lib/models/report_model.dart` | **NEW** | Report data object |
| `lib/widgets/app_button.dart` | UPDATED | Added `isLoading` (disabled + spinner) to prevent duplicate submissions |
| `lib/widgets/app_text_field.dart` | UPDATED | Added `maxLines`, `helperText`, `prefixIcon` |
| `lib/routes/app_routes.dart` | UPDATED | Registered the `/report` route |
| `lib/screens/home_screen.dart` | UPDATED | Added the "Go to Report Form" button |
| `lib/widgets/app_shell.dart` | UPDATED | Added "Report" to the nav bar and drawer |
| `lib/constants/app_constants.dart` | UPDATED | Added report categories and Caraga locations |

The Home, Login and Dashboard screens from Activity 8 were **not** replaced — the Report Form was added on top of the existing project and repository.

## The Four Essential Async UI States

`ReportUiState { idle, loading, success, empty, error }` — implemented in `report_form_screen.dart`.

| State | How it is triggered | Visible response |
|-------|---------------------|------------------|
| **LOADING** | Submit a valid form (async request pending) | Spinner in the button (`Submit Report...`, disabled) + "LOADING - Submitting your report" box |
| **SUCCESS** | The simulated request resolves without error | Green "SUCCESS - Report submitted" box with reference number and a "Submit another report" action |
| **EMPTY** | Open the Report Form before any report exists (no records) | "EMPTY - No report records" box + "Submitted Reports (0)" with a helpful message |
| **ERROR** | Turn on "Simulate API failure (demo only)", then submit | Red "ERROR - Report was not submitted" box with the reason and a working **Retry** button |

> All four responses are **simulated** (`Future.delayed`) because the REST API and PostgreSQL integration is planned for the next phase.

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

Demo login (local only, no backend yet): username `student`, password `1234`.
Report form demo: fill in title / category / location / description, then press **Submit Report**.

## Automated Tests

```bash
flutter analyze   # No issues found
flutter test      # 6 tests passed
```

The test file covers the Home shell, the Home -> Report Form navigation, the EMPTY state, field-level validation, LOADING -> SUCCESS, and ERROR -> Retry.

## Initial Pages/Screens Included

- [x] Home Page — landing with project info + route buttons
- [x] Login Page — form + validation (`AppTextField` + `AppButton`), local `AuthService`
- [x] Navigation Shell — AppBar + top nav buttons + Drawer, consistent theme
- [x] Dashboard / Module Placeholder — proves page transition works
- [x] **Report Form Screen (Activity 9)** — form + validation + 4 async UI states

## Repository Link and First Checkpoint

```bash
git init
git add .
git commit -m "Initial Flutter Web project - home/login/navigation shell"
git remote add origin https://github.com/andymarkcrasco-blip/activity8.git
git branch -M main
git push -u origin main
```

Activity 9 second checkpoint (same repository, same branch):

```bash
git add .
git commit -m "Add report form and Flutter UI states"
git push
```

- GitHub repo: **https://github.com/andymarkcrasco-blip/activity8**
- Checkpoint 1 (Activity 8): `c7497c3` — Initial Flutter Web project - home/login/navigation shell
- Checkpoint 2 (Activity 9): `1a14bf0` — Update group member to andymarkcrasco
- Checkpoint 3 (Activity 9): `1ef6ac3` — Add report form and Flutter UI states

## Evidence Screenshots

All screenshots are in `screenshots/` and are embedded in `ACTIVITY9_EVIDENCE_REPORT.docx` / `.pdf`.

| File | Content |
|------|---------|
| `shot0_home_navigation.png` | Home screen with the "Go to Report Form" button (Home -> Report Form navigation) |
| `shot1_explorer.png` | VS Code Explorer with the Activity 8 files and the new `lib/screens/report_form_screen.dart` |
| `shot2_reuse_code.png` | `AppTextField` from `lib/widgets/` used in **two** contexts: `report_form_screen.dart` (left) and `login_screen.dart` (right) |
| `shot2_report_form_chrome.png` | The running `report_form_screen.dart` in Google Chrome with the form fields and reused widgets |
| `shot3_loading.png` | LOADING state (button disabled + spinner) |
| `shot4_success.png` | SUCCESS state with the saved report reference |
| `shot5_empty.png` | EMPTY state (no report records) |
| `shot6_error.png` | ERROR state with the visible Retry action |

## How This Grows Into the Proposed System

The Activity 8/9 project is the Sprint 1 / first increment baseline of EventVenue Caraga: clean setup + version control + working shell + reusable components + real asynchronous UI states. Next increments replace `report_service.dart`'s simulated delay with the real REST API (PHP + MySQL) call, persist reports in PostgreSQL, and add role-based pages (client / vendor / admin) without restructuring the folders.

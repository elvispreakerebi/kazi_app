# Kazi App – Implementation Plan

## Overview
Kazi is a curriculum-automation app for teachers. The system consists of a Flutter frontend (cross-platform), and a Convex TypeScript backend. Both are organized for scalable, modular, and maintainable development.

---

## 1. Backend (Convex – TypeScript)

### Folder Structure (inside `/kazi_app/convex`)
```
convex/
├── schema.ts                # DB schema definitions
├── functions/               # Convex/TypeScript serverless functions
│    ├── auth.ts             # Authentication logic (email, Google)
│    ├── class.ts            # CRUD for classes, subjects
│    ├── file.ts             # File upload, parse, metadata
│    ├── lessonPlan.ts       # Lesson plan endpoints
│    └── ...                 # Other domain logic
├── types/                   # Custom types/shared interfaces (optional, for clarity)
├── utils/                   # Helpers/utilities (logging, etc.)
├── _generated/              # Convex-generated code (checked into repo)
```

### Backend Responsibilities
- Authentication (register, login: email/password + Google)
- Teacher, class, subject, curriculum, scheme, lesson plan models
- File upload, file metadata, and parsing endpoints
- Lesson plan CRUD and linkage to parsed scheme/curriculum
- Futurizable: Extensible for AI, analytics, progress tracking

---

## 2. Frontend (Flutter – Feature-First, Named Routes)

### Folder Structure (inside `/kazi_app/lib`)
```
lib/
├── app/                             # App-level config, entrypoint, routing
│   ├── app.dart                     # Global state/providers & material app
│   ├── main.dart                    # Actual entrypoint
│   ├── router.dart                  # Named routes, page transitions, guards
│   └── route_guard.dart             # Auth/logic for navigation guards
│
├── core/                            # App-wide utilities, themes, constants
│   ├── constants/
│   │   └── strings.dart             # String constants
│   ├── themes/
│   │   ├── app_theme.dart           # ThemeData, colors, etc.
│   └── utils/
│       └── validators.dart          # Form/input/email validators, etc.
│
├── shared/                          # Widgets/services usable by any feature
│   ├── widgets/
│   │   └── loading_indicator.dart   # Common widgets
│   └── services/
│       ├── api_service.dart         # (HTTP, etc. wrapper)
│       └── auth_service.dart        # (Shared auth logic)
│
├── features/                        # Major app features (modular, scalable)
│   ├── onboarding/
│   │   ├── onboarding_route.dart     # Routes for onboarding steps
│   │   ├── domain/
│   │   │   └── providers.dart        # Riverpod providers: onboarding progress/state
│   │   ├── presentation/
│   │   │   ├── step_add_classes_page.dart        # Step 1: Add classes
│   │   │   ├── step_add_subjects_page.dart       # Step 2: Add subjects
│   │   │   ├── step_add_schemes_page.dart        # Step 3: Add/upload scheme of work
│   │   │   ├── step_add_curriculum_page.dart     # Step 4: Add/upload/select curriculum
│   │   │   └── congratulations_page.dart         # Final congrats/finish screen
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart # Logic for API or Convex calls
│   │   │   └── models.dart          # Auth models
│   │   ├── domain/
│   │   │   └── auth_usecases.dart   # Business rules for login/register
│   │   ├── presentation/
│   │   │   ├── auth_page.dart       # Main auth screen
│   │   │   ├── login_form.dart      # Login widget
│   │   │   ├── register_form.dart   # Registration widget
│   │   │   └── providers.dart       # Riverpod providers/logic
│   │   └── auth_route.dart          # Route for this feature
│   │
│   ├── home/
│   │   ├── data/
│   │   │   ├── home_repository.dart
│   │   │   └── models.dart
│   │   ├── domain/
│   │   │   └── home_usecases.dart
│   │   ├── presentation/
│   │   │   ├── home_page.dart
│   │   │   └── providers.dart
│   │   └── home_route.dart
│   │
│   ├── settings/
│   │   ├── data/
│   │   │   └── settings_repository.dart
│   │   ├── domain/
│   │   │   └── settings_usecases.dart
│   │   ├── presentation/
│   │   │   ├── settings_page.dart
│   │   │   └── providers.dart
│   │   └── settings_route.dart
│   │
│   ├── classes/
│   │   ├── data/
│   │   │   ├── class_repository.dart
│   │   │   └── models.dart
│   │   ├── domain/
│   │   │   └── class_usecases.dart
│   │   ├── presentation/
│   │   │   ├── class_list_page.dart # List of classes
│   │   │   ├── class_detail_page.dart
│   │   │   └── providers.dart
│   │   └── classes_route.dart
│   │
│   ├── lesson_plans/
│   │   ├── data/
│   │   │   ├── lesson_plan_repository.dart
│   │   │   └── models.dart
│   │   ├── domain/
│   │   │   └── lesson_plan_usecases.dart
│   │   ├── presentation/
│   │   │   ├── lesson_plan_page.dart
│   │   │   ├── edit_lesson_plan_page.dart
│   │   │   └── providers.dart
│   │   └── lesson_plans_route.dart
│   │
│   └── ... (future features: analytics, notifications)
│
├── l10n/                            # Localization (if needed)
│   └── app_en.arb
│
└── test/                            # Test code, mirrors lib structure
```

### Structure Principles
- Each feature is self-contained (scalable for large teams)
- Domain layer: Business logic/use cases – no UI code
- Data layer: Models, repository/service that call backend
- Presentation: Screens, widgets, state management (Riverpod, etc.)
- All navigation is via named routes, set up in `app/router.dart` with one route file per feature for modular routing
- App-wide types/utilities/themes/constants go in `core/`
- Shared widgets/services go in `shared/`
- All features and folders camel_case or snake_case (not kebab or Pascal)

### Minimal example: Adding a new feature
To add file uploading:
```
features/file_upload/
├── data/file_upload_repository.dart
├── domain/file_upload_usecases.dart
├── presentation/file_upload_page.dart
├── presentation/providers.dart
└── file_upload_route.dart
```

---

## 3. Teacher Onboarding Flow (Progressive, After Account Signup)

### Flow Overview
- After creating a new account, every teacher completes a 4-step onboarding workflow:
  1. **Add Classes**: Create one or more classes that the teacher manages.
  2. **Add Subjects**: Add subjects to each class (e.g. Math, Science per class).
  3. **Add Schemes of Work**: Upload/select a scheme of work for each subject.
  4. **Add/Select Curriculum**: Upload or select curriculum file for the teacher (optional or required).
- After steps 1–4, show a **Congratulations page** (completion state, next steps/options to explore app).
- Steps are progressive (user cannot skip ahead), and the flow is reformatted for UX on mobile/web/desktop.

### Frontend Implementation
- All onboarding screens/pages live under a new feature folder:
  - `features/onboarding/presentation/step_add_classes_page.dart`
  - `features/onboarding/presentation/step_add_subjects_page.dart`
  - `features/onboarding/presentation/step_add_schemes_page.dart`
  - `features/onboarding/presentation/step_add_curriculum_page.dart`
  - `features/onboarding/presentation/congratulations_page.dart`
  - Shared onboarding logic/state in `features/onboarding/domain/providers.dart` (Riverpod AsyncNotifier etc.)
- Navigation through steps happens via named routes (`app/router.dart`). Step guards ensure steps completed in order.
- UX: Each step has inline validation and progress indicator/steps bar.
- For file uploads (scheme, curriculum), use Flutter file picker and connect to backend API.

### Backend Implementation
- Endpoints required:
  - Add class (mutation)
  - Add subject (mutation, must include class linkage)
  - Upload scheme of work (mutation + file upload, linked to subject)
  - Upload/select curriculum (mutation + file upload)
- Must allow creation/association of credentials strictly related to the onboarding session for initial population.
- All onboarding data (classes, subjects, schemes, curriculum) must be available to teacher account at app home.

#### Todo
- [ ] **onboarding-flow:** Implement a progressive 4-step onboarding flow (add classes → add subjects → add scheme(s) of work → add/select curriculum → Congratulations) with guards, progress, and backend/API connectivity.

---

## 4. Implementation Tasks (Frontend & Backend)

### Backend
- [ ] **auth-setup:** Implement authentication mutation and query functions (email/pass/Google)
- [ ] **data-model:** Complete Convex schema for all core entities
- [ ] **accounts-api:** Register, login, basic profile endpoints
- [ ] **class-api:** CRUD for classes and subjects
- [ ] **file-upload-api:** Endpoint for file uploads and metadata save
- [ ] **file-parse-service:** Parse uploaded curriculum/scheme; save structured data
- [ ] **lesson-plan-api:** CRUD for lesson plans, linked to content parsed from files
- [ ] **teacher-dashboard-basics:** (Optional) Teacher dashboard stats endpoint

### Frontend
- [ ] **frontend-structure:** Scaffold directories/files as above for feature-first, scalable Flutter
- [ ] **router-setup:** Implement central named route management, route guards
- [ ] **landing-pages:** Create starter widgets/screens for onboarding, login, home, settings

---

## 5. References
- [Flutter scalable folder structure guides 2024–2025](https://www.pravux.com/best-practices-for-folder-structure-in-large-flutter-projects-2025-guide/)
- [Convex Dev Best Practices](https://docs.convex.dev/understanding/best-practices/)

## 6. Notes
- All team code must conform to these conventions for maintainability.
- Review and refactor folder placement as the app grows.

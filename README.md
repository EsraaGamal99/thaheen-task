# Thaheen Task — Flutter Course Tracker

A Flutter application that lets users browse courses, watch lesson videos, and automatically tracks their watch progress — with sequential lesson unlocking enforced at the 90 % completion threshold.

---

## Getting Started

### Prerequisites

| Requirement | Version |
|---|---|
| Flutter | 3.x (tested on 3.47.4) |
| Dart SDK | ≥ 3.0.0 < 4.0.0 |
| Xcode (iOS) | 14 + |
| Android Studio / SDK | API 21 + |

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Generate code (assets & localization keys)

```bash
dart run build_runner build --delete-conflicting-outputs
```

> This generates `lib/gen/` (typed asset references via **flutter_gen**) and `lib/core/translations/locale_keys.g.dart` (typed i18n keys via **easy_localization**).

### 3. Run the app

```bash
# Development (hot-reload)
flutter run

# Specific device
flutter run -d <device-id>
```

### 4. Run tests

```bash
flutter test
```

---

## Architecture & State-Management Choices

### Clean Architecture (feature-first)

The project is organised into two top-level layers inside `lib/`:

```
lib/
├── core/                  # Shared infrastructure (DI, routing, theme, i18n, …)
└── features/
    ├── courses/
    │   ├── data/
    │   │   ├── data_sources/   # Local data sources (SharedPreferences)
    │   │   ├── models/         # Plain Dart models with JSON serialisation
    │   │   └── repositories/   # Repository that wraps data sources
    │   └── presentation/
    │       ├── cubit/          # Business logic & state
    │       ├── screens/        # Full-page widgets
    │       └── widgets/        # Reusable UI pieces
    └── splash/
```

**Why feature-first?** Each feature is self-contained — data, logic, and UI all live together — so the codebase scales without cross-feature coupling.

### State Management — flutter_bloc (Cubit)

`CoursesCubit` is the single source of truth for course data and lesson progress. It exposes a set of well-defined states:

| State | When emitted |
|---|---|
| `CoursesInitial` | Before any data is fetched |
| `CoursesLoading` | While courses are being loaded |
| `CoursesSuccess` | Courses loaded; carries the list + the full `progressMap` |
| `CoursesProgressUpdated` | After a lesson's progress is saved; carries the updated `progressMap` |
| `CoursesError` | On any failure |

**Why Cubit over plain Bloc?** The interactions here (load data, update progress, reload) are simple method calls with no complex event-to-state mapping needed. Cubit removes the boilerplate of explicit `Event` classes while remaining fully testable.

### Dependency Injection — get_it

All dependencies are registered in `lib/core/di/dependency_injection.dart` via `GetIt` lazy singletons. `SharedPreferences` is instantiated before `runApp()` and injected at registration time, so every data source receives the same instance without rebuilding it.

### Persistence — SharedPreferences

Progress is stored as a single JSON blob under the key `lessons_progress_data`:

```json
{
  "lesson-id-1": {
    "lessonId": "...",
    "courseId": "...",
    "lastPositionSec": 45,
    "totalDurationSec": 120,
    "isCompleted": false,
    "lastWatchedAt": "2026-09-25T22:00:00.000Z"
  }
}
```

`LessonProgressLocalDataSource` is the only class that reads/writes this key, keeping persistence concerns isolated.

### Lesson Unlock & Completion Logic

Two core rules drive the UX:

1. **90 % rule** — A lesson is marked `isCompleted = true` the first time the playback position reaches ≥ 90 % of the total duration. Once completed, the flag is never cleared, even if the user seeks backward (enforced by an `OR` with `wasAlreadyCompleted` in `updateLessonProgress`).

2. **Sequential unlock** — `isLessonUnlocked(index, lessons)` returns `true` only if `index == 0` or the lesson at `index - 1` is completed. The UI (both `ExpandableCard` and `LessonPlayerScreen`) enforces this gate.

### Localisation — easy_localization

The app ships with Arabic (default) and English translation JSON files under `assets/lang/`. Type-safe keys are generated into `locale_keys.g.dart`. `LocaleCubit` in `core/cubit/locale/` persists the user's language preference via `SharedPreferences`.

### Video Playback — video_player + chewie

`video_player` handles the low-level platform channel; `chewie` adds the full-featured UI controls (play/pause, seek bar, full-screen toggle with automatic orientation lock). Progress is persisted on `dispose()` and the player resumes from the last saved position on next open.

---

## Trade-offs & Known Issues

### Trade-offs made

| Decision | Trade-off |
|---|---|
| **SharedPreferences for persistence** | Simple and zero-setup, but not suitable for large datasets or relational queries. A proper local DB (Isar, Drift) would be the next step if the content library grows. |
| **Single JSON blob for all progress** | Eliminates the need for a DB schema at this scale. However, read/write cost is O(n) with the number of lessons, and concurrent writes (rare in a single-user mobile app) are not atomic. |
| **`ExpandableCard` reads progress directly from `sl<LessonProgressLocalDataSource>()`** | Avoids prop-drilling through the widget tree but bypasses the cubit, meaning the card does not react to live progress changes — it shows the snapshot at build time. |
| **Course data bundled as a local JSON asset** | Keeps the app fully offline and removes backend complexity for a task scope. In production this would be fetched from an API. |
| **`chewie` for video controls** | Ships a great default UI out of the box, but customising the controls layout requires forking or wrapping the package. |

### Known Issues

- **Progress not live-updated on the course details / expandable card** — After exiting the lesson player, the details screen must be navigated away from and back to see the fresh progress badge. A `BlocListener` re-emitting on route-pop, or lifting the `ExpandableCard` into the `BlocBuilder`, would fix this.
- **Lesson player accesses `sl()` directly** — The screen resolves its own `LessonProgressLocalDataSource` from the service locator rather than receiving it through the cubit, creating a second code path for saving progress that is not reflected in the cubit's `_progressMap` until `reloadProgress()` is called.
- **No error retry UI** — The `CoursesError` state is handled, but the current UI does not expose a retry button to the user.

### What I'd Do With More Time

1. **Lift progress state fully into the cubit** — Remove the direct `sl()` call inside `LessonPlayerScreen` and `ExpandableCard`. Route all reads and writes through `CoursesCubit`, so the UI always reflects the authoritative in-memory `_progressMap` without manual reloads.
2. **Replace SharedPreferences with a local database** — Use **Isar** or **Drift** for structured, queryable storage and proper atomic writes.
3. **Add widget & integration tests** — The current test suite covers core business logic (90 % rule, unlock rule, progress %) with unit tests. Widget tests for `ExpandableCard` and `LessonPlayerScreen` would significantly increase confidence.
4. **Implement "resume last lesson" banner** — `getLastUnfinishedLesson()` already exists on the cubit. A home-screen card prompting the user to continue where they left off would surface this.
5. **Retry / error-recovery UI** — Show a retry button when `CoursesError` is emitted instead of a bare error message.
6. **Offline-first course content** — Cache the course JSON from a remote API with a proper TTL and show stale data with an indicator.
7. **Dark mode** — Add a system-aware theme toggle so the app respects the device's dark/light preference and lets the user override it manually.
8. **Search courses** — Implement a real-time search bar on the courses screen that filters by title and description as the user types.
9. **Per-lesson notes saved locally** — Let learners jot down timestamped notes for each lesson, persisted in local storage and accessible from a dedicated notes panel.
10. **Remember the last playback speed** — Persist the user's chosen playback speed (e.g. 1.5×) across sessions so they never have to reset it after reopening the app.

---

## Time Spent

| Phase | Approx. time |
|---|---|
| Project setup, architecture scaffolding, DI, routing | ~30 m |
| Course listing UI (courses screen, expandable cards) | ~2 h |
| Lesson player (video_player + chewie integration, orientation handling) | ~1 h |
| Progress tracking logic (90 % rule, sequential unlock, persistence) | ~2 h |
| Unit tests (3 core logic test groups) | ~1 h |
| **Total** | **~6.5 h** |

<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-09-26 at 08 16 16" src="https://github.com/user-attachments/assets/02047650-8eeb-47b2-9f6d-dec1c5afe21e" /> <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-09-26 at 08 17 40" src="https://github.com/user-attachments/assets/2d0b02c0-42e4-49ce-aeb9-4f58c450dab3" /> <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-09-26 at 08 16 43" src="https://github.com/user-attachments/assets/eb421d7e-2f19-4434-9963-f23d7b4f3315" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-09-26 at 08 18 33" src="https://github.com/user-attachments/assets/b8a1d3f4-dbd3-4c4f-8cf4-b8a3496d95b8" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-09-26 at 08 17 40" src="https://github.com/user-attachments/assets/b5fa30b8-83e7-45d9-bcd7-c571a5fe522c" /> <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-09-26 at 08 21 42" src="https://github.com/user-attachments/assets/13946f31-0837-4bac-9778-38ee54ec7042" />


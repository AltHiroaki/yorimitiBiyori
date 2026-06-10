# AI Agent Rules for yorimitiBiyori

This document contains project-specific rules for AI agents working on `yorimitiBiyori`.

The rules below are written in English so they can be copied directly into AI agent instructions.

## Copyable instruction

~~~md
# AI Agent Rules for yorimitiBiyori

## Scope

This file defines project-specific rules for `yorimitiBiyori`.

For general coding quality rules, also follow `docs/SKILL.md`.

## Product Goal

`yorimitiBiyori` is a Flutter mobile app. The MVP targets Android only; iOS support is a post-MVP advanced phase.

The app helps users turn short free-time gaps into small actions or content discoveries based on their registered interests.

The core experience is:

1. The user registers interest categories.
2. The app sends a local notification.
3. The notification offers time actions such as 15, 30, and 60 minutes.
4. The user taps a time action.
5. The app opens the suggestion screen and shows one matching suggestion.
6. The user records whether they tried or skipped it.

## Highest Priority

Prioritize completing the MVP.

Do not add advanced integrations before the MVP is stable.

Do not implement or generate iOS platform files for the MVP unless explicitly requested. Keep iOS work in the advanced phase.

The MVP flow is:

1. Register interests.
2. Select available time in the app or from a notification action.
3. Suggest an item that matches the selected time and interests.
4. Record done or skipped.
5. Show history.

## MVP Features

The MVP includes only:

- interest category registration
- local notification setup
- notification time actions
  - 15 minutes
  - 30 minutes
  - 60 minutes
- suggestion based on selected time and interests
- re-suggestion
- done record
- skipped record
- history display
- basic settings screen

## Out of Scope Before MVP Completion

Do not implement the following unless explicitly requested:

- user login
- Google Calendar API
- Firebase Authentication
- Firestore
- Google Maps API
- Places API
- geolocation
- YouTube API
- music service integrations
- AI API calls
- cloud storage per user
- account-based synchronization

These are future features, not MVP requirements.

iOS implementation, iOS notification behavior, TestFlight distribution, and iPhone device verification are also post-MVP advanced-phase work.

## Technical Stack

Use the Flutter stack:

- Flutter
- Dart
- Material 3
- JSON asset data
- local device storage for MVP settings and records
- local notifications for MVP notification flow
- flutter_test for tests

Do not use the old React / Vite / Tailwind / React Router stack for new implementation work.

Do not add new external packages unless explicitly requested or clearly necessary.

## Directory Responsibilities

Follow this project structure.

- `lib/main.dart`
  - application entry point

- `lib/src/app/`
  - application-level setup
  - root app widget
  - navigation shell

- `lib/src/pages/`
  - page-level widgets
  - examples: `home_page.dart`, `suggestion_page.dart`, `history_page.dart`, `settings_page.dart`

- `lib/src/widgets/`
  - reusable UI widgets
  - cards, buttons, layout parts, empty states

- `lib/src/features/`
  - feature-specific logic and widgets
  - expected future examples: `interests`, `notifications`, `recommendation`, `records`, `settings`

- `lib/src/models/`
  - shared Dart data models

- `lib/src/repositories/`
  - data access and persistence logic

- `assets/data/`
  - static suggestion data
  - suggestion candidates should be managed in `assets/data/suggestions.json`

Do not make large directory-structure changes without a clear reason.

## Dart and Flutter Rules

- Avoid `dynamic` unless there is a clear reason.
- Define explicit models for suggestions, user settings, and records.
- Keep nullable values safe before using them.
- Prefer immutable model objects where practical.
- Keep build methods readable.
- Avoid putting complex filtering or random selection directly inside widgets.
- Use `const` constructors where possible.
- Keep page widgets responsible for page composition, not business logic.

## UI and Logic Separation

Flutter widgets should mainly handle rendering and user interaction.

Move these operations out of page widgets when they grow:

- loading suggestion JSON
- filtering suggestions
- selecting a random suggestion
- calculating completion rate
- reading device storage
- writing device storage
- parsing notification action IDs
- formatting dates or times

## Suggestion Data

Manage suggestion candidates in `assets/data/suggestions.json`.

When editing suggestion data:

- each suggestion must have a stable unique `id`
- titles should be short and understandable
- descriptions should be useful to the user
- required fields must not be missing
- `duration_minutes` must be a positive number
- `interest_tags` should match known interest category names
- update Dart models when the JSON structure changes

Representative data shape:

```json
{
  "id": "music_new_genre_15",
  "title": "普段聴かないジャンルを1曲だけ聴く",
  "description": "好きな音楽ジャンルに近いけれど、まだ触れていないジャンルを1曲だけ聴いてみる。",
  "category": "音楽",
  "interest_tags": ["音楽", "発見", "気分転換"],
  "duration_minutes": 15
}
```

## Suggestion Logic

The suggestion logic should use:

- selected available minutes
- registered interest categories

Rules:

- Load suggestions from `assets/data/suggestions.json`.
- Filter suggestions where `duration_minutes <= selectedMinutes`.
- Prefer suggestions whose `interest_tags` overlap with user interests.
- Select one random suggestion from matching candidates.
- Handle the case where no suggestion matches.
- Keep the first implementation simple.
- Avoid over-engineering ranking or AI generation before the base flow works.

## Records and Local Storage

Use local device storage for MVP history and settings.

Rules:

- Define storage keys as constants.
- Keep storage read/write logic in dedicated functions.
- Treat decoded data as fallible.
- Handle missing, invalid, or old stored data safely.
- Be careful when changing the saved data shape.
- Make history deletion behavior clear to the user.

Suggested storage keys:

```dart
const recordsStorageKey = 'yorimiti_biyori_records';
const settingsStorageKey = 'yorimiti_biyori_settings';
```

## Notification Flow

The notification flow is central to the mobile app concept.

MVP notification actions should be:

- 15 minutes
- 30 minutes
- 60 minutes

Do not add 45 minutes to notification actions in the MVP because notification action limits and platform behavior should be kept simple.

45 minutes may be added later as an in-app time option.

Notification implementation order:

1. Make in-app time selection work.
2. Show a basic local notification.
3. Open the app from a notification tap.
4. Add notification actions.
5. Pass the selected minutes to the suggestion screen.

## Testing

After code changes, run these when possible:

```bash
flutter analyze
flutter test
```

For MVP notification work, test on Android Emulator and a real Android device when possible.

iOS Simulator and iPhone device verification should be done in the post-MVP iOS phase.

If tests cannot be run, state that clearly.

## Prohibited Changes

Do not do the following unless explicitly requested:

- reintroduce the React / Vite web stack
- add AI API calls
- add Google APIs
- add Firebase
- add Maps or Places APIs
- add geolocation
- add YouTube or music service integrations
- add login or account synchronization
- make large directory-structure changes
- mix UI and business logic heavily
- contradict README or docs
- mix unrelated refactoring into feature work
- rewrite working code without explaining the impact

## Decision Priority

When unsure, follow this priority order:

1. Follow README and docs.
2. Move the MVP closer to completion.
3. Preserve readability and maintainability.
4. Keep the implementation simple.
5. Defer advanced features.
~~~

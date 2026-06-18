# AI Agent Rules for yorimitiBiyori

This document contains project-specific rules for AI agents working on `yorimitiBiyori`.

The rules below are written in English so they can be copied directly into AI agent instructions.

## Copyable instruction

~~~md
# AI Agent Rules for yorimitiBiyori

## Scope

This file defines project-specific rules for `yorimitiBiyori`.

For general coding quality rules, also follow `docs/rules/SKILL.md`.

## Source of Truth

The specification source of truth is:

1. The project proposal (企画書, `docs/spec/企画書.md` and the submitted PDF) — concept, data catalog design, processing flow, future phases.
2. The UI prototype in `よりみち日和 UIプロトタイプ/` — screen structure, UI copy, interaction flow. It is a Figma-exported React project and is **reference only**. Never copy React code or dependencies into the Flutter app.

When they conflict, follow the prototype for screens and UI text, and the proposal for data and logic. The implementer summary is `docs/spec/仕様要約.md`.

## Product Goal

`yorimitiBiyori` is a Flutter mobile app. The MVP targets Android only; iOS support is a post-MVP advanced phase.

The app suggests one small "yorimichi" (detour) action that fits the user's interest categories and current conditions (time, budget, travel distance) during short free-time gaps.

The core experience is:

1. On first launch the user completes onboarding: welcome modal → interest category selection → notification permission.
2. The app sends a daily local notification at the configured time (default 17:30).
3. The notification offers time actions: 15, 30, and 60 minutes.
4. The user taps a time action (or the notification body), which opens the suggestion screen.
5. The suggestion screen shows one matching suggestion with title, description, tags, and time.
6. "やってみる" opens a completion modal with feedback chips (よかった / 普通 / 合わなかった) and saves a done record.
7. "別の提案" records the current suggestion as skipped and re-draws with the same conditions.

## Highest Priority

Prioritize completing the MVP.

Do not add advanced integrations before the MVP is stable.

Do not implement or generate iOS platform files for the MVP unless explicitly requested. Keep iOS work in the advanced phase.

## Screens

Bottom NavigationBar with exactly 3 tabs. There is **no home screen**; the suggestion tab is the top screen.

- Tab 1 提案 (suggestion): current-conditions card + "今日のよりみち" suggestion card + info card
- Tab 2 履歴 (history): summary (done count / skipped count / total minutes) + recent records list; empty state with CTA to the suggestion tab
- Tab 3 設定 (settings): Google account row (advanced phase, show as 未連携), suggestion settings row, interest categories, notification time, notification toggle, history deletion with inline confirm, about
- Sub screen 提案設定 (suggestion settings): time / budget / distance / categories editor with AppBar back button, reachable from both the suggestion tab and the settings tab
- Onboarding (first launch only): welcome modal → category selection (3-step progress indicator) → notification permission dialog (allow / later)
- Completion modal: ModalBottomSheet after "やってみる" with 3 feedback choices and "履歴に保存"

## Suggestion Conditions

There is **no difficulty selection UI**. Per the proposal, the weight of an action is expressed through the time choice.

- Time: 5 / 15 / 30 / 60 minutes (FilterChip, single select). Notification actions offer only 15 / 30 / 60; 5 minutes is in-app only.
- Budget: 0円 / 500円以内 / 1000円以内 / 指定なし
- Distance: その場でできる / 徒歩5分以内 / 徒歩15分以内 / 少し遠くてもよい
- Interest categories (multi-select, 10): 散歩, 音楽, 読書, 学習, カフェ, 写真, 整理, 休憩, 運動, 買い物

Default conditions: 15分, 500円以内, 徒歩15分以内, categories [散歩, カフェ, 読書].

Time selected from a notification action is a temporary condition for that session; it must not overwrite the saved suggestion settings.

## MVP Features

The MVP includes only:

- onboarding flow (welcome → categories → notification permission)
- interest category registration (10 categories, multi-select)
- suggestion settings screen (time / budget / distance / categories)
- local notification at a configured time, with 15 / 30 / 60 minute actions
- suggestion display matching the conditions
- re-suggestion ("別の提案", records the shown suggestion as skipped)
- completion modal with feedback (good / normal / bad) saving a done record
- history display (done count, skipped count, total minutes, recent list, empty state)
- history deletion with confirmation
- settings screen

## Out of Scope Before MVP Completion

Do not implement the following unless explicitly requested:

- user login / Google account linking (the settings row may exist as a disabled/未連携 placeholder)
- Google Calendar API
- Firebase Authentication
- Firestore
- Google Maps API / Places API
- geolocation
- YouTube API
- music service integrations
- AI API calls (Claude API detail generation is advanced Phase 1)
- cloud storage per user
- account-based synchronization
- random notification time within a user-selected time range

iOS implementation, iOS notification behavior, TestFlight distribution, and iPhone device verification are also post-MVP advanced-phase work.

## Technical Stack

Use the Flutter stack:

- Flutter
- Dart
- Material 3 (green theme; seed from the prototype primary `#3F6F44`)
- JSON asset data (`assets/data/suggestions.json`)
- shared_preferences for MVP settings and records
- flutter_local_notifications for the MVP notification flow
- flutter_test for tests

Do not use the old React / Vite / Tailwind / React Router stack for new implementation work. The `よりみち日和 UIプロトタイプ/` folder is a design reference, not an implementation target.

Do not add new external packages unless explicitly requested or clearly necessary.

## Directory Responsibilities

Follow this project structure.

- `lib/main.dart`
  - application entry point

- `lib/src/app/`
  - application-level setup
  - root app widget
  - navigation shell (3 tabs)

- `lib/src/pages/`
  - page-level widgets
  - examples: `suggestion_page.dart`, `history_page.dart`, `settings_page.dart`, `suggestion_settings_page.dart`

- `lib/src/widgets/`
  - reusable UI widgets
  - cards, chips, modals, empty states

- `lib/src/features/`
  - feature-specific logic and widgets
  - expected future examples: `onboarding`, `notifications`, `recommendation`, `records`, `settings`

- `lib/src/models/`
  - shared Dart data models (Suggestion, UserSettings, SuggestionRecord)

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
- weighted random selection
- calculating history totals
- reading device storage
- writing device storage
- parsing notification action IDs
- formatting dates or times

## Suggestion Data

Manage suggestion candidates in `assets/data/suggestions.json`. Target 50+ entries at initial release (per the proposal).

When editing suggestion data:

- each suggestion must have a stable unique `id`
- titles should be short and understandable
- descriptions should be useful to the user
- required fields must not be missing
- `min_minutes` must be a positive number and `min_minutes <= max_minutes`
- `category` must be one of the 10 known category display names
- `location_type` must be one of `spot` / `walk5` / `walk15` / `far`
- `budget_yen` must be a non-negative number (0 means free)
- update Dart models when the JSON structure changes

Representative data shape (per the proposal's action catalog design):

```json
{
  "id": "walk_theme_15",
  "title": "近くを15分だけ散歩する",
  "description": "スマホをしまって、いつも通らない道を少しだけ歩いてみる。気分転換に向いた軽いよりみちです。",
  "detail": "出発前に「今日は建物を見る」などテーマを1つ決めると、いつもの道でも発見が増えます。",
  "category": "散歩",
  "tags": ["気分転換", "散歩"],
  "min_minutes": 10,
  "max_minutes": 15,
  "intensity": "light",
  "location_type": "walk5",
  "budget_yen": 0,
  "where_to_try": "自宅や職場の周りで、普段曲がらない角を1つ曲がってみる。",
  "weight": 1.0
}
```

## Suggestion Logic

The suggestion logic should use:

- selected available minutes (time)
- budget option
- distance option
- registered interest categories

Rules:

- Load suggestions from `assets/data/suggestions.json`.
- Filter: `min_minutes <= selectedMinutes`.
- Filter: `budget_yen <=` the budget cap (no cap for 指定なし).
- Filter: `location_type` within the selected distance (inclusion order: spot ⊂ walk5 ⊂ walk15 ⊂ far).
- Filter: `category` or `tags` overlap with the user's selected categories.
- Exclude the last 3 shown suggestion ids (`recent_suggestion_ids`).
- Select one suggestion by weighted random (`weight`).
- If no candidates remain, temporarily lift the recent-exclusion (still avoid showing the same suggestion twice in a row).
- If still no candidates, show a message prompting the user to relax conditions.
- Keep the first implementation simple. Avoid over-engineering ranking or AI generation before the base flow works.

## Records and Local Storage

Use shared_preferences for MVP history and settings.

Rules:

- Define storage keys as constants.
- Keep storage read/write logic in dedicated functions.
- Treat decoded data as fallible.
- Handle missing, invalid, or old stored data safely.
- Be careful when changing the saved data shape.
- Make history deletion behavior clear to the user (inline confirmation, irreversible).
- A done record stores feedback (`good` / `normal` / `bad`); a skipped record stores `feedback = null`.
- "別の提案" records the currently shown suggestion as skipped before re-drawing.

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

Do not add 5 minutes (or any other duration) to notification actions in the MVP because notification action limits and platform behavior should be kept simple. 5 minutes is an in-app option only.

For the MVP, schedule notifications at the configured fixed time (default 17:30). Random notification timing within a user-selected time range is an advanced feature after the fixed-time notification flow is stable. If implemented later, use a bounded range such as 17:00-21:00 and re-schedule the next notification after each delivery instead of using a daily repeating fixed notification.

Tapping the notification body opens the suggestion screen.

Notification implementation order:

1. Make in-app condition selection work (suggestion settings screen).
2. Show a basic local notification.
3. Open the suggestion screen from a notification tap.
4. Add notification actions.
5. Pass the selected minutes to the suggestion screen as a temporary condition.

If notification permission is denied, the app must remain fully usable with manual suggestions.

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

- reintroduce the React / Vite web stack (including copying code from the UI prototype folder)
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

1. Follow the proposal (企画書) and the UI prototype, then README and docs.
2. Move the MVP closer to completion.
3. Preserve readability and maintainability.
4. Keep the implementation simple.
5. Defer advanced features.
~~~

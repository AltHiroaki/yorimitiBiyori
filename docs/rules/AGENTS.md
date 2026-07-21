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

1. The project proposal (企画書 ver6, `docs/spec/企画書.md` and the submitted PDF) — concept, **two-stage model (category → per-category detail settings)**, data catalog design, processing flow, future phases. In ver6 the MVP core categories are 音楽/料理/読書/映画 (4), and each MVP detail setting is a single "genre" group. The ver6 PDF lists a `difficulty` catalog field, but this project does not use it (difficulty is not implemented).
2. The UI prototype in `よりみち日和 UIプロトタイプ/` — screen structure, UI copy, interaction flow. It is a Figma-exported React project and is **reference only**. Never copy React code or dependencies into the Flutter app.

When they conflict, follow the proposal for the suggestion-conditions model (two-stage), data, and logic, and the prototype for other screens and UI text. The implementation spec is `docs/spec/仕様書.md` and the summary is `docs/spec/仕様要約.md`.

**Note:** the prototype's `SuggestSettingsScreen.tsx` still uses the old universal model (time / budget / distance) and must be updated to the two-stage model; follow `docs/spec/仕様書.md` §3.4, not the old prototype screen.

## Product Goal

`yorimitiBiyori` is a Flutter mobile app. The MVP targets Android only; iOS support is a post-MVP advanced phase.

The app suggests one small "yorimichi" (detour) action that fits the user's interest categories and per-category detail settings during short free-time gaps. The model is **two-stage**: the user picks categories, then refines each with a category-specific detail setting. In the MVP each category exposes a single "genre" group; multiple detail-setting groups (language, mood, time, budget, source, etc.) are an advanced-phase extension.

The core experience is:

1. On first launch the user completes onboarding: welcome modal → interest category selection → notification permission.
2. In 提案設定, the user picks categories, then sets each category's detail settings.
3. The app sends one local notification per day at a random time within the user-configured range (default 17:00–21:00). The wording is a soft invitation that does NOT name a duration (e.g. "暇な時間って存在しますか？"). There are no time-selection notification actions.
4. The user taps the notification body, which opens the suggestion screen (suggestion produced from the saved category + detail settings).
5. The suggestion screen shows one matching suggestion with title, description, tags, where-to-try, and budget.
6. "やってみる" opens a completion modal with feedback chips (よかった / 普通 / 合わなかった) and saves a done record.
7. "別の提案" records the current suggestion as skipped and re-draws with the same conditions.

## Highest Priority

Prioritize completing the MVP.

Do not add advanced integrations before the MVP is stable.

Do not implement or generate iOS platform files for the MVP unless explicitly requested. Keep iOS work in the advanced phase.

## Screens

Bottom NavigationBar with exactly 3 tabs. There is **no home screen**; the suggestion tab is the top screen.

- Tab 1 提案 (suggestion): current-conditions card (selected categories + active detail settings) + "今日のよりみち" suggestion card (title, description, tags, where-to-try, budget) + info card
- Tab 2 履歴 (history): summary (done count / skipped count / total minutes) + recent records list; empty state with CTA to the suggestion tab
- Tab 3 設定 (settings): Google account row (advanced phase, show as 未連携), suggestion settings row, interest categories, notification time, notification toggle, history deletion with inline confirm, about
- Sub screen 提案設定 (suggestion settings): **two-stage** editor — stage 1 category multi-select, stage 2 per-category detail-setting groups — with AppBar back button, reachable from both the suggestion tab and the settings tab
- Onboarding (first launch only): welcome modal → category selection (3-step progress indicator) → notification permission dialog (allow / later)
- Completion modal: ModalBottomSheet after "やってみる" with 3 feedback choices and "履歴に保存"

## Suggestion Conditions (two-stage)

There is **no difficulty, no universal time condition, and no travel-distance condition** (removed from the old model; the ver6 PDF `difficulty` field is not implemented in this project). Conditions are set in two stages:

1. **Stage 1 — category selection** (multi-select, MVP 4 categories): music 音楽 / cook 料理 / read 読書 / movie 映画. walk 散歩 is an advanced-phase category (definition + data retained in `InterestCategories.developmentCategories`).
2. **Stage 2 — per-category detail settings** (each group is multi-select; unselected = 指定なし = no filtering). **In the MVP each category exposes a single "genre" group:**
   - 音楽: ジャンル(ポップス/ジャズ/クラシック/洋楽)
   - 料理: 味覚・ジャンル(和食/洋食/中華/イタリアン/アジア風/激辛/さっぱり/ガッツリ)
   - 読書: ジャンル(エッセイ/小説/ノンフィクション/詩集/ミステリー・サスペンス/SF・ファンタジー/ビジネス・自己啓発/歴史・教養) — a single suggestion's `tags` may hold more than one of these values (e.g. a mystery novel tagged both 小説 and ミステリー・サスペンス)
   - 映画: ジャンル(アクション/コメディ/ドラマ/SF/サスペンス/ファンタジー/恋愛/アニメ/ミステリー) — a single suggestion's `tags` may hold more than one of these values, since one movie can span multiple genres
   - 散歩 (advanced): 目的(気分転換/運動/発見)

   Advanced-phase detail settings (企画書 ver6 表3 "発展版で追加"): 音楽=言語・気分, 料理=栄養素・ダイエット, 読書=読書時間・入手予算, 映画=上映時間・視聴先.

See `docs/spec/仕様書.md` §3.4 for the master table. Default categories are [music, read, movie]; detail settings default to all-unselected (指定なし). Categories and detail-setting groups must be driven from a master definition so more can be added later (散歩, 運動, 芸術, etc.).

## MVP Features

The MVP includes only:

- onboarding flow (welcome → categories → notification permission)
- interest category registration (MVP 4 categories, multi-select)
- suggestion settings screen (two-stage: category selection → per-category detail settings; MVP is one "genre" group per category)
- local notification once per day at a random time within the configured range, soft wording without naming a duration, no time-selection actions
- suggestion display matching the category + detail-setting conditions (card shows where-to-try and budget)
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

Manage suggestion candidates in `assets/data/suggestions.json`. Grow toward 50+ entries per category as an advanced goal.

> `assets/data/suggestions.json` is on the ver6 schema (per-category ids, `tags` = detail-setting values, `budget_yen`, `estimated_minutes`, `weight`). It no longer uses `min_minutes` / `max_minutes` / `intensity` / `location_type`. The ver6 PDF `difficulty` field is not used in this project.

When editing suggestion data:

- each suggestion must have a stable unique `id`
- titles should be short and understandable
- descriptions should be useful to the user
- required fields must not be missing
- `category` must be one of the known category ids (`music` / `cook` / `read` / `movie`; `walk` is retained as an advanced-phase category)
- `tags` holds the values that correspond to the category's detail-setting options (this is what the filter matches against)
- `budget_yen` must be a non-negative number (0 means free)
- `estimated_minutes` is the rough duration used for history total-minutes aggregation
- there is **no** `min_minutes` / `max_minutes` / `intensity` / `location_type`
- update Dart models when the JSON structure changes

Representative data shape:

```json
{
  "id": "music_jazz_focus",
  "title": "作業用にジャズを1曲だけ流す",
  "description": "歌詞のないジャズを1曲、作業や勉強のBGMにしてみる。集中したいときに向いた軽いよりみちです。",
  "detail": "配信サービスの「作業用ジャズ」プレイリストから1曲選ぶだけでOK。",
  "category": "music",
  "tags": ["ジャズ", "作業向け", "無料"],
  "budget_yen": 0,
  "where_to_try": "音楽配信アプリで「作業用 ジャズ」と検索してプレイリストを開く。",
  "estimated_minutes": 5,
  "weight": 1.2
}
```

## Suggestion Logic

The suggestion logic should use:

- selected interest categories
- per-category detail settings (`detail_settings`)

Rules:

- Load suggestions from `assets/data/suggestions.json`.
- Filter: `category` must be one of the user's selected categories.
- Filter: for the matched category, for each detail-setting group the user has selected values in, at least one selected value must be in the suggestion's `tags` (OR within a group, AND across groups). Unselected groups do not filter. Across categories the match is OR.
- Filter: if a budget detail-setting is selected, also apply `budget_yen <=` the cap.
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

The notification is the entry point that nudges the user to open the app. The suggestion itself is produced from the saved category + detail settings.

- The notification wording is a soft invitation that does NOT name a duration, e.g. "暇な時間って存在しますか？" / "ちょっとした空き時間、ありませんか？".
- There are **no time-selection notification actions** (the old 15 / 30 / 60 minute actions are removed, because time is no longer a universal condition).
- Tapping the notification body opens the suggestion screen.

Notifications fire once per day at a random time within a user-selected bounded range (`notification_start_time`–`notification_end_time`, default 17:00–21:00; start == end means a fixed time and is how the legacy single `notification_time` is migrated). Because Android provides no delivery callback, the implementation pre-schedules 7 single-shot notifications (IDs 4101–4107, one per day) and re-schedules them on every app launch via `applySettings`; a persisted plan (`yorimiti_biyori_scheduled_notification_plan`) prevents scheduling a second notification for a day whose planned time has already passed. Known limitation: if the app is not opened for 7+ days, notifications stop until the next launch. Do not use a fully random time, multiple notifications per day, or `matchDateTimeComponents` daily repeats.

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

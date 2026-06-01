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

`yorimitiBiyori` is a web application that suggests small actions users can do during short free-time gaps.

The app uses:

- available time
- activity intensity
- location
- budget

to suggest an activity that can be done immediately.

The first target users are university students who have 15 to 60 minutes between classes, part-time work, or club activities.

## Highest Priority

Prioritize completing the MVP.

Do not add advanced features before the MVP is stable.

The core flow is:

1. Enter available time, intensity, location, and budget.
2. Suggest an activity that matches the conditions.
3. Record whether the user did or skipped the activity.
4. Show history and completion rate.

## MVP Features

The MVP includes only:

- manual available-time input
- intensity selection
- location selection
- budget selection
- activity suggestion based on conditions
- re-suggestion
- done record
- skipped record
- history display
- completion rate display

## Out of Scope Before MVP Completion

Do not implement the following unless explicitly requested:

- Google login
- Google Calendar API
- Firebase Authentication
- Firestore
- Google Maps API
- Places API
- geolocation
- automatic free-time detection between calendar events
- cloud storage per user
- account-based synchronization

These are future features, not MVP requirements.

## Technical Stack

Use the existing stack:

- React
- TypeScript
- Vite
- Tailwind CSS
- React Router
- localStorage
- JSON data

Do not add new external libraries unless explicitly requested or clearly necessary.

Prefer standard TypeScript, React, and browser APIs for simple logic.

## Directory Responsibilities

Follow this project structure.

- `src/app/`
  - application-level setup
  - routing
  - example: `router.tsx`

- `src/pages/`
  - page-level components
  - examples: `HomePage.tsx`, `SuggestPage.tsx`, `HistoryPage.tsx`, `SettingsPage.tsx`

- `src/components/`
  - reusable UI components
  - layout components
  - shared buttons, cards, forms, and UI parts

- `src/features/`
  - feature-specific logic and components
  - examples: `activities`, `recommendation`, `records`

- `src/data/`
  - static application data
  - activity candidates should be managed in `activities.json`

- `src/types/`
  - shared TypeScript types

- `src/utils/`
  - generic utility functions

Do not make large directory-structure changes without a clear reason.

## TypeScript Rules

- Avoid `any`.
- Define explicit types for activity data, suggestion conditions, and activity records.
- Put shared types in `src/types/`.
- Small page-local types may stay in the same file.
- Handle nullable values before using them.
- Keep TypeScript types aligned with `activities.json`.

Representative type examples:

```ts
type Intensity = "low" | "medium" | "high";

type Activity = {
  id: string;
  title: string;
  description: string;
  durationMinutes: number;
  intensity: Intensity;
  location: string;
  budgetYen: number;
};

type ActivityRecord = {
  id: string;
  activityId: string;
  status: "done" | "skipped";
  createdAt: string;
};
```

Adjust actual types to match the real data structure.

## React Rules

- Use function components.
- Type component props.
- Keep page components responsible for page composition.
- Move reusable UI into `src/components/`.
- Move growing business logic into `src/features/` or `src/utils/`.
- Avoid putting complex filtering, mapping, or conditionals directly inside JSX.

## UI and Logic Separation

React components should mainly handle rendering and user interaction.

Move these operations out of page components when they grow:

- filtering activity candidates
- selecting a random suggestion
- calculating completion rate
- reading from localStorage
- writing to localStorage
- converting form input values
- formatting dates or times

## Activity Data

Manage activity candidates in `src/data/activities.json`.

When editing activity data:

- each activity must have a stable unique `id`
- titles should be short and understandable
- descriptions should be useful to the user
- fields required for filtering must not be missing
- update TypeScript types when the JSON structure changes

## Suggestion Logic

The suggestion logic should use:

- available time
- intensity
- location
- budget

Rules:

- Filter activities from `activities.json`.
- Keep suggestion logic separate from UI components.
- Handle the case where no activity matches.
- Keep the first implementation simple.
- Avoid over-engineering repeat-prevention logic before the base suggestion flow works.

## Records and localStorage

Use localStorage for MVP history storage.

Rules:

- Define storage keys as constants.
- Keep localStorage read/write logic in dedicated functions.
- Treat `JSON.parse` as fallible.
- Handle missing, invalid, or old stored data safely.
- Be careful when changing the saved data shape.
- Make history deletion behavior clear to the user.

Suggested storage key:

```ts
const STORAGE_KEY = "yorimiti-biyori-records";
```

## Completion Rate

Calculate completion rate from records.

Suggested definition:

```text
done count / (done count + skipped count)
```

If there are no records, avoid division by zero. Show either `0%` or an empty-state message.

## Styling

Use Tailwind CSS as the default styling method.

- Prefer mobile-first UI.
- Reuse common button, card, and layout components.
- Keep spacing, border radius, shadows, and colors consistent.
- Avoid repeating long class-name groups across many files.
- Keep the UI lightweight and easy to understand for university students using the app during short breaks.

## Routing

Keep routing configuration in `src/app/router.tsx`.

Use these basic routes:

```text
/
/suggest
/history
/settings
```

Place route page components in `src/pages/`.

## Build Check

After code changes, run this when possible:

```bash
npm run build
```

If the build fails, fix the error when it is within the task scope.

If the build cannot be run, state that clearly.

## Prohibited Changes

Do not do the following unless explicitly requested:

- add new external dependencies
- implement features outside the MVP scope
- add Google APIs
- add Firebase
- add Maps or Places APIs
- add geolocation
- make large directory-structure changes
- use `any` broadly
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

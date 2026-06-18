# General Coding Skill for AI Agents

This document contains general coding rules for AI agents and developers.

The rules below are written in English so they can be copied directly into AI agent instructions.

## Copyable instruction

~~~md
# General Coding Skill

## Core Principle

Prioritize readability above all else.

Prefer clear, explicit code over short or clever code. Code should be easy to understand, easy to modify, and difficult to misuse.

When making implementation decisions, use this priority order:

1. Correct behavior
2. Readability
3. Maintainability
4. Simplicity
5. Conciseness

Do not optimize for fewer lines if the result is harder to understand.

## Readability

Write code for humans first.

- Use names that describe the purpose of the value or function.
- Split complex expressions into named intermediate variables.
- Keep control flow simple.
- Prefer early returns over deeply nested conditionals.
- Avoid clever one-liners when a step-by-step implementation is clearer.
- Keep related logic close together.
- Do not mix unrelated changes in the same edit.

Avoid this:

```ts
const r = items.filter((x) => x.a <= m && x.b <= p).sort(() => Math.random() - 0.5)[0];
```

Prefer this:

```ts
const matchedItems = items.filter((item) => {
  return item.requiredMinutes <= availableMinutes
    && item.requiredBudget <= selectedBudget;
});

const selectedItem = getRandomItem(matchedItems);
```

## Naming

Use specific, intention-revealing names for variables, functions, types, and components.

Avoid vague names unless the scope is extremely small and the meaning is obvious.

Avoid names such as:

- `data`
- `item`
- `temp`
- `result`
- `flag`
- `value`
- `handleClick`

Prefer names such as:

- `activities`
- `matchedActivities`
- `selectedActivity`
- `activityRecords`
- `isHistoryEmpty`
- `handleSubmitCondition`

Boolean names should read like true-or-false statements.

Examples:

```ts
const isHistoryEmpty = records.length === 0;
const canSubmitCondition = availableMinutes > 0;
const hasMatchedActivities = matchedActivities.length > 0;
```

## Magic Numbers

Do not use meaningful numbers directly in application logic.

Use named constants so the meaning of each value is clear.

Avoid this:

```ts
if (availableMinutes >= 15) {
  // ...
}
```

Prefer this:

```ts
const MIN_ACTIVITY_MINUTES = 15;

if (availableMinutes >= MIN_ACTIVITY_MINUTES) {
  // ...
}
```

Acceptable exceptions:

- `0` for the first array index
- `+ 1` for incrementing by one
- `100` for percentage calculations
- obvious boolean values
- empty strings when used as empty input values
- small local UI values when extracting them would reduce readability

## Type Safety

Use TypeScript types to make invalid states difficult to represent.

- Avoid `any`.
- Define explicit types for important data structures.
- Keep type definitions aligned with actual data.
- Handle `null` and `undefined` before using values.
- Avoid type assertions unless there is a specific reason.
- Prefer union types for fixed sets of values.

Avoid this:

```ts
function saveRecord(record: any) {
  // ...
}
```

Prefer this:

```ts
type ActivityRecord = {
  id: string;
  activityId: string;
  status: "done" | "skipped";
  createdAt: string;
};

function saveRecord(record: ActivityRecord) {
  // ...
}
```

## Function Responsibility

A function should have one clear purpose.

Do not combine too many responsibilities in one function, such as:

- reading input
- filtering data
- selecting a random item
- saving data
- updating UI state
- formatting display text

Split long or mixed-purpose functions into smaller named functions.

Prefer this structure:

```ts
const matchedActivities = filterActivities(activities, condition);
const selectedActivity = getRandomActivity(matchedActivities);
saveActivityRecord(selectedActivity);
```

## Conditional Logic

Avoid deeply nested conditionals.

Handle invalid or empty cases early, then keep the main path easy to read.

Avoid this:

```ts
if (user) {
  if (records.length > 0) {
    if (selectedRecord) {
      // ...
    }
  }
}
```

Prefer this:

```ts
if (!user) {
  return;
}

if (records.length === 0) {
  return;
}

if (!selectedRecord) {
  return;
}

// ...
```

## Comments

Comments should explain why, not what.

Avoid comments that simply repeat the code.

Avoid this:

```ts
// Save records
localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
```

Prefer this:

```ts
// The MVP has no login, so records are stored only in the browser.
localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
```

Use comments for:

- non-obvious business rules
- temporary constraints
- decisions that may look strange without context
- trade-offs
- known limitations

## Duplication and Abstraction

Avoid unnecessary duplication, but do not abstract too early.

- If the same logic appears in multiple places, consider extracting it.
- If future reuse is unclear, keep the implementation direct and readable.
- Prefer simple duplication over premature abstraction when the abstraction would be harder to understand.
- Extract shared logic only when the shared responsibility is clear.

## Side Effects

Separate pure calculations from side effects when possible.

Side effects include:

- localStorage access
- API calls
- navigation
- console output
- reading the current time
- generating random values

Prefer keeping pure logic in functions that receive input and return output. This makes behavior easier to test and easier to reason about.

## Error Handling

Treat fallible operations as fallible.

Add error handling for:

- `JSON.parse`
- localStorage access
- API calls
- date parsing
- data shape mismatches
- user input conversion

The UI should not break when stored data is missing, invalid, or outdated.

User-facing error messages should be short, concrete, and actionable.

## Dependencies

Do not add new dependencies unless they are clearly necessary.

Before adding a dependency:

1. Check whether the platform, TypeScript, React, or existing dependencies can solve the problem.
2. Consider the maintenance cost.
3. Consider bundle size and complexity.
4. Explain why the dependency is needed.

Do not add a dependency only to avoid writing a small amount of straightforward code.

## Change Discipline

When editing existing code:

- Keep the change focused.
- Avoid unrelated refactoring.
- Preserve existing behavior unless changing it is part of the task.
- Follow the existing project structure.
- Keep documentation and implementation consistent.
- Run the available build or check command when possible.
- If a check cannot be run, state that clearly.

## Output Expectations for AI Agents

When completing a coding task, summarize:

- what changed
- why it changed
- files touched
- checks performed
- any remaining risks or follow-up work
~~~

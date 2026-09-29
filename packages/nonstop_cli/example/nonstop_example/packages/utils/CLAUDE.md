# Nonstop Example: `packages/utils`

Pure, dependency-light formatting extensions on `double`, `num`, `int` and
`DateTime` (layer 0). It owns stateless value-to-string helpers only: no DI
registration, no `init()`, no widgets, no I/O, no workspace dependencies.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API

Exported from `package:utils/utils.dart`.

| Symbol | Member | Output |
|---|---|---|
| `DoubleFormatting` on `double` | `format({decimalPlaces = 1})` | `NumberFormat('#.#...')`; drops a trailing `.0` (`2.0` -> `2`) |
| | `asScore()` | `format(decimalPlaces: 1)` |
| `NumFormatting` on `num` | `compact()` | `NumberFormat.compact()` in the default `intl` locale (`1250` -> `1.25K` in `en`) |
| `IntTimeFormatting` on `int` | `asTime({sec, min, hr})` | Seconds -> `59 sec`, `1 min`, `1 min 1 sec`, `1 hr`, `1 hr 1 min`; unit labels overridable |
| `DateTimeFormatting` on `DateTime` | `formatRelative({now, justNow, yesterday, minutesAgo, hoursAgo, daysAgo})` | `Just now`, `Nm ago`, `Nh ago`, `Yesterday`, `Nd ago`, else `DateFormat.yMd()` in the default locale; every label overridable |

## Layout

| Path | Responsibility |
|---|---|
| `lib/utils.dart` | Barrel |
| `lib/src/number_formatter.dart` | `DoubleFormatting`, `NumFormatting`, `IntTimeFormatting` |
| `lib/src/date_time_formatter.dart` | `DateTimeFormatting` |

## Rules

- Only dependency is `intl` (plus the Flutter SDK). Keep it that way; a helper that needs `core`, `di` or an SDK belongs in that package.
- Extensions are pure functions of their receiver and arguments. Time-dependent code takes an optional clock value (`formatRelative({now})`) so tests are deterministic.
- Add a new topic as a new file under `lib/src/` exported from `lib/utils.dart`, rather than growing an unrelated one.
- Any user-visible word is a parameter with an English default; callers pass `strings.*` values. Never import `localization` here.
- Display dates for UI already have `core`'s `DateTimeConverter`; do not duplicate those formats here.

## Common changes

- **Add a formatter:** add a method to the matching extension (or a new extension in `lib/src/<topic>.dart`, exported from `lib/utils.dart`), and add boundary cases to `test/formatters_test.dart`.
- **Change a threshold in `asTime` / `formatRelative`:** update the boundary tables in the existing tests first; they enumerate every branch.

## Tests

`test/formatters_test.dart` covers decimal formatting, `asScore`, `compact` (including a `de` locale via `Intl.withLocale`), all `asTime` boundaries (0, 59, 60, 61, 3599, 3600, 3660) plus custom labels, and every `formatRelative` branch with an injected `now`, one real-clock call and custom labels. Pattern: `Map<input, expected>` tables iterated in a loop.

Run: `dart run melos exec --scope=utils -- flutter test`. `dart run melos run coverage` must stay 100%.

## Gotchas

- Label defaults (`sec`, `min`, `hr`, `Just now`, `Yesterday`, `Nm ago`) are English; for user-facing copy pass localized labels from the call site.
- `compact()`, `format()` and the `formatRelative` date fallback follow the default `intl` locale (`Intl.defaultLocale`).
- `formatRelative` treats future dates as `Just now` (negative difference is `< 1` minute).
- The app's `pubspec.yaml` depends on `utils`, but no Dart code in `apps/` or `features/` imports it yet.

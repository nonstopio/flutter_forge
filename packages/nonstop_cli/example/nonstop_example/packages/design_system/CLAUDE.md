# Nonstop Example: `packages/design_system`

The visual language of the app: theme, shared components, dialogs, screens,
toasts and loaders. It is product-agnostic: no feature names, no business
logic, no navigation decisions. Layer 3 (see `packages/CLAUDE.md`).

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first. **Load the
`design-system` skill** before adding or changing anything here; it holds the
rules for tokens, components and review.

## Public API

Everything, including `Toast`, is exported from
`package:design_system/design_system.dart`.

| Symbol | Kind | Use |
|---|---|---|
| `DesignSystemWrapper` | widget | Wraps `MaterialApp`; picks light/dark from platform brightness, installs `GlobalLoaderOverlay` and `ToastificationWrapper` |
| `DesignSystem` | theme builder | `light()` / `dark()` `ThemeData`; `bodyFont` / `displayFont` (default "Open Sans") |
| `MaterialTheme` | generated | Color schemes (light, dark, contrast variants) |
| `createTextTheme` | generated | Merges Google Fonts body + display text themes |
| `NavigationIcons` | constants | Every navigation icon; one edit re-skins the shell |
| `Toast` | static API | `notification`, `error`, `success`, `warning` |
| `Loader` / `DefaultLoader` | overlay / widget | Blocking overlay; inline adaptive spinner |
| `DefaultErrorView`, `ErrorScreen` | widgets | Inline error with retry; full-screen error with retry/home |
| `NetworkUrlImage`, `AppAssetImage`, `Header` | widgets | Cached network image, raster/SVG asset with fallback, header banner |
| `DateFilterChips` | widget | Week/month filter |
| `AuthHeadersBuilder` | widget | Builds a child with current auth headers |
| `FileInfoDialog` | dialog | `FileInfoDialog.show(context, file)`; tap-to-copy confirms with `Toast.success` |

## Layout

| Path | Responsibility |
|---|---|
| `lib/design_system.dart` | `DesignSystem`: component theme overrides on top of `MaterialTheme` |
| `lib/generated/` | Material Theme Builder export (`theme.dart`, `util.dart`). Never hand-edit |
| `lib/components/` | Reusable widgets (`app_asset_image.dart`, ...), hand-maintained `index.dart` barrel |
| `lib/screens/`, `lib/dialogs/` | Full screens and dialogs |
| `lib/toast/`, `lib/loader/` | Toast and overlay APIs |
| `lib/wrapper/wrappers.dart` | `DesignSystemWrapper` |
| `lib/constants/navigation_icons.dart` | Navigation icon set |
| `lib/utils/extensions/` | Package-private string helpers |

## Rules

- Component styling (buttons, app bar, navigation bar, inputs) is set once in
  `DesignSystem._baseTheme`. Change it there, not with per-widget `style:`.
- Colors come from `Theme.of(context).colorScheme` roles; text from
  `textTheme`. Components never use raw `Color(...)`; even input borders use
  `outlineVariant`.
- Every user-visible string comes from `strings.*` (`localization`).
- Components take everything they render as constructor parameters. They
  never call `di.get`, except `AuthHeadersBuilder`, which falls back to the
  registered `AuthTokenProvider` / `Logger` when none is passed.
- `network` (`AuthTokenProvider`) and `core` (`Logger`) are imported only by
  `AuthHeadersBuilder`. Do not add other imports from them.
- The wrapper owns brightness. The app passes only `theme:` to
  `MaterialApp.router`; do not add a separate `darkTheme` there.

## Common changes

- **Rebrand the palette:** export from Material Theme Builder, replace
  `lib/generated/theme.dart` wholesale, then check both brightnesses.
- **Change fonts:** pass `bodyFont` / `displayFont` to `DesignSystem` in
  `DesignSystemWrapper` (any Google Fonts family name).
- **Add a component:** follow the `design-system` skill. Add a file to
  `lib/components/`, export it from `components/index.dart`, and test it in
  `test/components_test.dart`.
- **Add a toast variant:** add a static method to `Toast` that mirrors the
  others, and add it to the toast test in `test/integration_test.dart`.

## Tests

| File | Covers |
|---|---|
| `design_system_test.dart` | Wrapper hands the builder a themed context |
| `components_test.dart` | Theme building, loaders, error view/screen, asset fallbacks, network image, wrapper brightness + loader, string helpers |
| `integration_test.dart` | Image adapters, `AuthHeadersBuilder` (missing provider, failures, rebuilds), dialogs, toast variants |

Run `dart run melos exec --scope=design_system -- flutter test`. Keep
`dart run melos run coverage` at 100%.

## Gotchas

- Google Fonts are fetched at runtime. For offline-first or production builds,
  bundle the font files as assets and set
  `GoogleFonts.config.allowRuntimeFetching = false`.
- `FileInfoDialog` takes a `dart:io` `File`, so it does not work on web. Its
  labels ("File Information", "File Name", ...) are still raw English
  literals, not `strings.*`.

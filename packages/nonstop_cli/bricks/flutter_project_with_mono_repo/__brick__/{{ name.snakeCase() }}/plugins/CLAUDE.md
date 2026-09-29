# {{name.titleCase()}}: `plugins/`

Native platform integrations (method/event channels, FFI). Read the root
`CLAUDE.md` first. Create one with:

```sh
nonstop create my_plugin --template plugin -o plugins
```

`nonstop create` registers it in the workspace. It also adds a starter `CLAUDE.md`;
fill it in like every other member (see the `melos-workspace` skill). A plugin that renders UI
follows the `design-system` skill.

## Rules

- Check pub.dev for a maintained plugin before writing one.
- A plugin depends on nothing in `apps/`, `features/` or `packages/`.
- Expose a Dart contract; keep channel names, argument maps and platform
  exceptions private to the plugin. Convert `PlatformException` into typed
  exceptions at the boundary.
- Every platform the plugin declares in `pubspec.yaml` must be implemented or
  throw `UnimplementedError` with a clear message.
- Native code follows the platform's conventions (Kotlin for Android, Swift for
  iOS). Do not block the platform main thread.
- Tests mock the channel with `TestDefaultBinaryMessengerBinding`; native code
  gets its own platform tests when it has logic.

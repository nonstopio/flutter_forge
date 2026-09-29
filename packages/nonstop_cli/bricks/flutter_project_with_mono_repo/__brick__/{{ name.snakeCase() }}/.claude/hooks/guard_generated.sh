#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit): refuse hand edits to generated files.
# Fails open: anything unexpected exits 0 so a broken hook never blocks work.
path=$(sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
case "$path" in
  *.g.dart|*.freezed.dart|*.i69n.dart)
    echo "Blocked: $path is generated. Edit its source, then run 'dart run melos run generate' (or 'generate:i69n' for localization)." >&2
    exit 2 ;;
  */design_system/lib/generated/*)
    echo "Blocked: $path comes from Material Theme Builder. Replace the file wholesale with a new export." >&2
    exit 2 ;;
  *pubspec.lock)
    echo "Blocked: pubspec.lock is written by 'dart pub get'. Change pubspec.yaml instead." >&2
    exit 2 ;;
esac
exit 0

#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit): format the Dart file that was just written,
# so the lint gate never fails on formatting. Always exits 0.
path=$(sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
case "$path" in
  *.g.dart|*.freezed.dart|*.i69n.dart) ;;
  *.dart) [ -f "$path" ] && dart format "$path" >/dev/null 2>&1 ;;
esac
exit 0

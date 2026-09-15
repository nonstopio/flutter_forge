# Flutter mono-repo template

The default NonStop CLI template: a Melos-managed application, reusable packages
and optional feature/SDK modules. See the [CLI guide](../../README.md) for module
flags and the generate → improve → verify → port → regenerate workflow.

The generated README and `docs/architecture.md` describe the architecture,
configuration and testing contract. All handwritten runtime Dart is subject to
a 100% executable-line coverage gate; generated code, tools and native code are
outside that scope.

After editing `__brick__` or hooks, rebuild the embedded bundle from the CLI
package directory and run its tests and `tool/verify_template.dart`. Do not edit
the encoded bundle directly. Contract tests reject stale bundled source and
invalid Dart across all 512 module selections; CI also exercises fresh projects.

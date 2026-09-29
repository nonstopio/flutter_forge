# Example

```sh
# Activate Nonstop CLI
dart pub global activate nonstop_cli

# See list of available commands
nonstop --help

# Create a mono-repo project
nonstop create my_app
```

## Reference output

[`nonstop_example/`](nonstop_example) is the committed output of
`nonstop create` with every module enabled. It shows exactly what a new project
contains, including its Claude Code setup (`CLAUDE.md` files, `.claude/`
hooks and skills). It is regenerated from the bricks, never edited by hand:

```sh
dart run melos run generate:nonstop_example   # from the flutter_forge root
```

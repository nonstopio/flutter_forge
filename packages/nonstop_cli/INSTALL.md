# Installing nonstop_cli

## Using `dart pub`

Install the latest version:
```sh
dart pub global activate nonstop_cli
```

Install a specific version:
```sh
dart pub global activate nonstop_cli <version>
```

> If you haven't already, you might need to
> [set up your path](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path).

## Alternative Installation Methods

### Running without installation (e.g., in CI environments):
```sh
dart pub global run nonstop_cli:nonstop <command> <args>
```

### Using Flutter
```sh
flutter pub global activate nonstop_cli
```

## Verifying Installation

After installation, verify that the CLI is installed correctly:

```sh
nonstop --version
```

If you see the version number, the installation was successful.

## Updating

To update to the latest version:
```sh
nonstop update
```

Or directly using dart pub:
```sh
dart pub global activate nonstop_cli
```
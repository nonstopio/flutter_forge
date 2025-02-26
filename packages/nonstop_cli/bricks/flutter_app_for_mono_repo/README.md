# flutter_app_for_mono_repo

A brick to create a Flutter application for a Melos-managed mono-repo.

## Features

- Creates a Flutter application using `flutter create`
- Configures the application for a mono-repo structure
- Removes analysis_options.yaml to use the root one from mono-repo
- Sets up proper folder structure for the app

## Usage

```shell
nonstop create my_project --template=app
```

## Variables

| Variable      | Description                       | Default       | Type     |
|---------------|-----------------------------------|---------------|----------|
| `name`        | The name of the project           | -             | `string` |
| `description` | The description of the project    | -             | `string` |
| `org_name`    | The organization name for the app | `com.example` | `string` |
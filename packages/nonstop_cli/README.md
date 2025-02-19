<p align="center">
  <a href="https://nonstopio.com">
    <img src="https://github.com/nonstopio.png" alt="Nonstop Logo" height="128" />
  </a>
  <h1 align="center">NonStop</h1>
  <p align="center">Digital Product Development Experts for Startups & Enterprises</p>
  <p align="center">
    <a href="https://github.com/nonstopio/flutter_forge">Docs</a> |
    <a href="https://nonstopio.com">Website</a>
  </p>
</p>

# nonstop_cli

[![nonstop_cli](https://img.shields.io/pub/v/nonstop_cli.svg?label=nonstop_cli&logo=dart&color=blue&style=for-the-badge)](https://pub.dev/packages/nonstop_cli)

A command-line interface for the Flutter to generate Flutter projects from
predefined templates.

# Quick Start 🚀

## Installing 🧑‍💻

```sh
dart pub global activate nonstop_cli
```

Or install a [specific version](https://pub.dev/packages/nonstop_cli/versions)
using:

```sh
dart pub global activate nonstop_cli <version>
```

> If you haven't already, you might need to
> [set up your path](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path).

When that is not possible (eg: CI environments), run `nonstop` commands via:

```sh
dart pub global run nonstop_cli:nonstop <command> <args>
```

# Commands ✨

## `nonstop doctor`

Nonstop Doctor is a command-line tool that helps developers set up and troubleshoot
their Flutter development environment.

- Ensure that the required software is installed
- Diagnose issues and provide recommendations

```sh
nonstop doctor
```

<img width="678" alt="nonstop doctor" src="_images/cli_doctor.png">


## Usage

### Create project `nonstop create`

Create a Flutter project in seconds based on the predefined template.


```sh
nonstop nonstop create <project-name> [arguments]
```


<img width="851" alt="nonstop create super_app" src="_images/cli.png">


```sh
Usage: nonstop create <project-name> [arguments]
-h, --help                Print this usage information.
    --application-id      The bundle identifier on iOS or application id on Android. (defaults to <org-name>.<project-name>)
-o, --output-directory    The desired output directory when creating a new project.
    --description         The description for this new project.
                          (defaults to "A Flutter project created by Nonstop CLI.")
    --org-name            The organization for this new project.
                          (defaults to "com.example")

Run "nonstop help" to see global options.
```

## Contact

Follow us, stay up to date or reach out on:

- [LinkedIn](https://www.linkedin.com/company/nonstop-io)
- [X.com](https://x.com/NonStopio)
- [Instagram](https://www.instagram.com/nonstopio_technologies/)
- [YouTube](https://www.youtube.com/@NonStopioTechnology)
- [Email](mailto:contact@nonstopio.com)

---

<p align="center">Made with ❤️ by <a href="https://github.com/ProjectAJ14">Ajay Kumar</a></p>


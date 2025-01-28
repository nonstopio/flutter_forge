#!/usr/bin/env just --justfile

# Upgrade your Flutter and Dart packages
upgrade_pub_packages:
    melos exec -- flutter pub upgrade

# Generate JSON serializables for a package
_generate-json package command="build":
    #!/usr/bin/env bash
    echo "Building JSON-Serializable in {{package}}"
    cd {{package}}
    dart run build_runner {{command}} --delete-conflicting-outputs



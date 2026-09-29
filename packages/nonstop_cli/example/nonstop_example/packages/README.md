# Packages

Horizontal capabilities shared across features: networking, design system,
logging, analytics, dependency injection.

A package here must not depend on a `features/` package - dependencies point
inward, from features to packages.

Add one with:

```sh
nonstop create my_package --template package -o packages
```

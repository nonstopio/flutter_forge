# Features

Vertical slices of the product. A feature owns its UI, state and data access,
and exposes two things to the app:

- an `init()` that registers its services with the locator
- a `Router` exposing the routes the app splices into its route table

Features may depend on `packages/`, and should avoid depending on each other.

Add one with:

```sh
nonstop create package my_feature -o features
```

# Apps

Runnable Flutter applications. An app wires modules together in
`lib/bootstrap.dart` and composes feature routes in `lib/router/router.dart` -
it should hold almost no business logic of its own.

Add another (an admin build, a white-label variant) with:

```sh
nonstop create app my_other_app -o apps
```

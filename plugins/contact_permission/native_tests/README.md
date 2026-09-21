# Native unit coverage

Run both native suites on macOS with Xcode command line tools, Python 3, and JDK 21:

```sh
python3 plugins/contact_permission/native_tests/run.py
```

Linux can run the Android suite alone:

```sh
python3 plugins/contact_permission/native_tests/run.py --platform android
```

The Gradle wrapper pins Gradle 9.7.1 with its distribution SHA-256. The JVM suite
uses Kotlin 2.4.20 and JaCoCo 0.8.15. The Apple suite uses the installed Xcode Swift
and Clang compilers with LLVM source coverage. Both commands fail unless every
executable line in the production native sources is covered. Reports are written
under `native_tests/coverage` and `native_tests/android/build/reports/jacoco`.

The tests compile the actual Kotlin, Swift, and Objective-C production files.
Android, Flutter embedding, and Apple Contacts SDK boundaries
are replaced by deterministic test doubles. The JVM cases cover engine and
activity lifecycle, granted/denied/missing permission results, method dispatch,
main-queue replies, and single completion. The Apple cases cover all authorization
states, successful/denied/error permission requests, method dispatch, channel
registration, and Objective-C-to-Swift registration forwarding. Android callbacks
run through the real kotlinx.coroutines implementation with its official test
dispatcher, so tests control the main queue without launching Android UI threads.

Only production classes/files enter the native coverage denominator; test doubles
and test harness code do not. These are native unit tests: they do **not** validate
system permission dialogs, real Android/iOS embedding integration, or OS behavior.
No test requests real contact access. Device integration tests remain a separate
validation boundary.

The production plugin now uses Android API 24 and iOS 15 deployment minima,
matching the [Flutter 3.47 support matrix](https://docs.flutter.dev/reference/supported-platforms).
Its Android build follows the [Flutter plugin Kotlin migration](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors).
AndroidX Core stays at 1.18.0 because 1.19.0 requires compile SDK 37, above this
plugin's compile SDK 36. AGP 9.4.1 and kotlinx.coroutines 1.11.0 are pinned.

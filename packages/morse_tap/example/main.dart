// Keep the original example entrypoint working while sharing the maintained app.
import 'package:morse_tap_example/main.dart' as app;

export 'package:morse_tap_example/main.dart' hide main;

void main() => app.main();

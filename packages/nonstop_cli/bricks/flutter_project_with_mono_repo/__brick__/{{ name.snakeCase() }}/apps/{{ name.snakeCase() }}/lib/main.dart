import 'package:flutter/material.dart';
import 'package:{{name.snakeCase()}}/app.dart';
import 'package:{{name.snakeCase()}}/bootstrap.dart' as bootstrap;

void main() async {
  await bootstrap.init();
  runApp(const App());
}

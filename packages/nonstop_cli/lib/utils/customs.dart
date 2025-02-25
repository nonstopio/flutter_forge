import 'package:mason/mason.dart';

typedef MasonGeneratorFromBundle = Future<MasonGenerator> Function(MasonBundle);

typedef MasonGeneratorFromBrick = Future<MasonGenerator> Function(Brick);

final RegExp identifierRegExp = RegExp('[a-z_][a-z0-9_]*');
final RegExp orgNameRegExp = RegExp(r'^[a-zA-Z][\w-]*(\.[a-zA-Z][\w-]*)+$');

import '../convenience_schemas.dart';
import 'widget_schemas.dart';

/// Flutter-specific convenience extensions for the Z class
///
/// This extension provides factory methods for Flutter widget schemas
/// when the flutter.dart library is imported.
extension ZFlutterExtensions on Z {
  /// Create a Color schema for Flutter Color validation
  static ColorSchema color() => ColorSchema();

  /// Create an EdgeInsets schema for Flutter EdgeInsets validation
  static EdgeInsetsSchema edgeInsets() => EdgeInsetsSchema();

  /// Create a Duration schema for Dart/Flutter Duration validation
  static DurationSchema duration() => DurationSchema();

  /// Create a Size schema for Flutter Size validation
  static SizeSchema size() => SizeSchema();
}

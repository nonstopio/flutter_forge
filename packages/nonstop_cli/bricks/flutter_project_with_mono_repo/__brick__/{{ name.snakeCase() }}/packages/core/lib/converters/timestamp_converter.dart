{{#firestore}}import 'package:cloud_firestore/cloud_firestore.dart';
{{/firestore}}import 'package:json_annotation/json_annotation.dart';

/// Accepts the three shapes a timestamp arrives in - ISO string,{{#firestore}}
/// Firestore [Timestamp],{{/firestore}} or the `{_seconds, _nanoseconds}` map that
/// Cloud Functions emit - and always writes back UTC ISO-8601.
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    final parsed = _tryParse(json);
    if (parsed == null) {
      throw ArgumentError('Invalid timestamp format: $json');
    }
    return parsed;
  }

  @override
  String? toJson(DateTime? date) => date?.toUtc().toIso8601String();
}

class TimestampConverterNullable implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverterNullable();

  @override
  DateTime? fromJson(dynamic json) => _tryParse(json);

  @override
  String? toJson(DateTime? date) => date?.toUtc().toIso8601String();
}

DateTime? _tryParse(dynamic json) {
  if (json is String && json.isNotEmpty) return DateTime.parse(json).toLocal();
{{#firestore}}  if (json is Timestamp) return json.toDate();
{{/firestore}}  if (json is Map<String, dynamic>) {
    final seconds = json['_seconds'] as int;
    final nanoseconds = json['_nanoseconds'] as int? ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000 + nanoseconds ~/ 1000000,
    );
  }
  return null;
}

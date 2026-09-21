import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_firebase_utils/extensions/map.dart';
import 'package:ns_firebase_utils/src.dart';
import 'package:ns_firebase_utils/utils/custom_exception.dart';

void main() {
  test('map helpers return typed values and defaults for invalid data', () {
    appLogsNS('default logger');
    errorLogsNS('default error logger');
    final timestamp = Timestamp.fromMillisecondsSinceEpoch(1234);
    final values = {
      'time': timestamp,
      'point': const GeoPoint(12, 34),
      'invalid': 1
    };
    expect(values.getTimestamp('time'), timestamp);
    expect(values.getTimestamp('absent'), isNull);
    expect(values.getTimestamp('invalid', defaultValue: timestamp), timestamp);
    expect(values.getGeoPoint('point'), const GeoPoint(12, 34));
    expect(values.getGeoPoint('absent'), const GeoPoint(0, 0));
    expect(values.getGeoPoint('invalid'), const GeoPoint(0, 0));
  });
  test('custom exceptions retain their diagnostic fields', () {
    final error =
        CustomException(code: 'failure', message: 'message', details: 42);
    expect(error.code, 'failure');
    expect(error.message, 'message');
    expect(error.details, 42);
    expect(error.toString(), 'NSFException(failure, message, 42)');
    expect(CustomException(code: 'empty').toString(),
        'NSFException(empty, null, null)');
  });
}

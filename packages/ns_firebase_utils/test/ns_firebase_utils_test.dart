import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_firebase_utils/constants.dart';

void main() {
  // Test constants
  test('defaultBool', () => expect(defaultBool, false));
  test('defaultInt', () => expect(defaultInt, 0));
  test('defaultDouble', () => expect(defaultDouble, 0.0));
  test('defaultString', () => expect(defaultString, ''));
  test('defaultMap', () => expect(defaultMap, {}));
  test('defaultList', () => expect(defaultList, []));
  test('defaultGeoPoint', () => expect(defaultGeoPoint, GeoPoint(0, 0)));
}

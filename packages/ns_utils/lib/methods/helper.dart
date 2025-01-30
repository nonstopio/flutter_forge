import 'package:objectid/objectid.dart';

String generateDbId() {
  return ObjectId().hexString;
}

String get uniqueId => ObjectId().hexString;

String get uniqueObjectId => ObjectId().hexString;

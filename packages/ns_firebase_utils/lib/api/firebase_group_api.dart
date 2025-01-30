import 'package:cloud_firestore/cloud_firestore.dart';

SetOptions mergeOption = SetOptions(
  merge: true,
);

class FirebaseGroupApi {
  final String collection;
  late Query<Map<String, dynamic>> query;

  FirebaseGroupApi(this.collection) {
    query = FirebaseFirestore.instance.collectionGroup(collection);
  }
}

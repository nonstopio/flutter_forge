import 'package:cloud_firestore/cloud_firestore.dart';

SetOptions mergeOption = SetOptions(
  merge: true,
);

class FirebaseApi {
  final String path;
  late CollectionReference ref;
  final FirebaseFirestore _firestore;

  FirebaseApi(this.path, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    ref = _firestore.collection(path);
  }

  Future<QuerySnapshot> getDataCollection() {
    return ref.get();
  }

  Stream<QuerySnapshot> streamDataCollection() {
    return ref.snapshots();
  }

  Future<DocumentSnapshot> getDocumentById(String id) {
    return ref.doc(id).get();
  }

  DocumentReference getDocumentRef({String? id}) {
    return ref.doc(id);
  }

  Future<void> removeDocument(String id) {
    return ref.doc(id).delete();
  }

  Future<DocumentReference> addDocument(
      {String? id, required Map<String, dynamic> data}) async {
    final docRef = ref.doc(id);
    await docRef.set(data);
    return docRef;
  }

  WriteBatch batch() {
    return _firestore.batch();
  }

  Future<void> updateDocument(
      {String? id, required Map<String, dynamic> data}) {
    return ref.doc(id).set(
          data,
          mergeOption,
        );
  }
}

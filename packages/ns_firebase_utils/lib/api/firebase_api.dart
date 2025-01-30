import 'package:cloud_firestore/cloud_firestore.dart';

SetOptions mergeOption = SetOptions(
  merge: true,
);

class FirebaseApi {
  final String path;
  late CollectionReference ref;

  FirebaseApi(this.path) {
    ref = FirebaseFirestore.instance.collection(path);
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
    return FirebaseFirestore.instance.batch();
  }

  Future<void> updateDocument(
      {String? id, required Map<String, dynamic> data}) {
    return ref.doc(id).set(
          data,
          mergeOption,
        );
  }
}

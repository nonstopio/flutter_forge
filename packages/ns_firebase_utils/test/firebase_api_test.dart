import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_firebase_utils/api/firebase_api.dart';
import 'package:ns_firebase_utils/api/firebase_group_api.dart' as group;

void main() {
  test(
      'CRUD, snapshots, document references and batches share the injected store',
      () async {
    final firestore = FakeFirebaseFirestore();
    final api = FirebaseApi('users', firestore: firestore);
    expect(api.path, 'users');
    expect((await api.getDataCollection()).docs, isEmpty);
    final document =
        await api.addDocument(id: 'alice', data: {'name': 'Alice'});
    expect(document.id, 'alice');
    expect((await api.getDocumentById('alice')).data(), {'name': 'Alice'});
    expect(api.getDocumentRef(id: 'alice').path, 'users/alice');
    expect(api.getDocumentRef().id, isNotEmpty);
    await api.updateDocument(id: 'alice', data: {'age': 30});
    expect((await api.getDocumentById('alice')).data(),
        {'name': 'Alice', 'age': 30});
    expect((await api.streamDataCollection().first).docs, hasLength(1));
    final generated = await api.addDocument(data: {'name': 'Generated'});
    expect(generated.id, isNotEmpty);
    final batch = api.batch();
    batch.set(api.getDocumentRef(id: 'batch'), {'batched': true});
    await batch.commit();
    expect((await api.getDataCollection()).docs, hasLength(3));
    await api.removeDocument('alice');
    expect((await api.getDocumentById('alice')).exists, isFalse);
  });

  test('collection groups collect matching nested collections', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.doc('users/a/items/one').set({'value': 1});
    await firestore.doc('users/b/items/two').set({'value': 2});
    final api = group.FirebaseGroupApi('items', firestore: firestore);
    expect(api.collection, 'items');
    expect((await api.query.get()).docs.map((doc) => doc.data()['value']),
        unorderedEquals([1, 2]));
    expect(group.mergeOption.merge, isTrue);
    expect(mergeOption.merge, isTrue);
  });
}

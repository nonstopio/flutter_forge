import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ns_firebase_utils/storage/firebase_storage_service.dart';

class MockStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockUploadTask extends Mock implements UploadTask {}

class MockSnapshot extends Mock implements TaskSnapshot {}

void main() {
  setUpAll(() {
    registerFallbackValue(File('fallback'));
    registerFallbackValue(SettableMetadata());
    registerFallbackValue(() {});
  });

  for (final reportProgress in [true, false]) {
    test('uploads file and metadata with progress reporting $reportProgress',
        () async {
      final storage = MockStorage();
      final root = MockReference();
      final reference = MockReference();
      final task = MockUploadTask();
      final snapshot = MockSnapshot();
      final events = StreamController<TaskSnapshot>.broadcast();
      addTearDown(events.close);
      when(() => storage.ref()).thenReturn(root);
      when(() => root.child('avatars/alice.png')).thenReturn(reference);
      when(() => reference.putFile(any(), any())).thenAnswer((_) => task);
      when(() => task.snapshotEvents).thenAnswer((_) => events.stream);
      when(() => snapshot.bytesTransferred).thenReturn(25);
      when(() => snapshot.totalBytes).thenReturn(100);
      when(() => snapshot.state).thenReturn(TaskState.success);
      when(() => task.whenComplete(any())).thenAnswer((invocation) async {
        events.add(snapshot);
        await Future<void>.delayed(Duration.zero);
        (invocation.positionalArguments.single as void Function())();
        return snapshot;
      });
      when(() => reference.getDownloadURL())
          .thenAnswer((_) async => 'https://example.test/alice.png');
      final file = File('avatar.png');
      final progress = <String>[];
      final result = await FirebaseStorageService.uploadFile(
        file,
        'avatars/alice.png',
        customMetadata: {'owner': 'alice'},
        onProgress: reportProgress ? progress.add : null,
        storage: storage,
      );
      expect(result, 'https://example.test/alice.png');
      expect(progress, reportProgress ? ['25.00'] : isEmpty);
      final metadata = verify(() => reference.putFile(file, captureAny()))
          .captured
          .single as SettableMetadata;
      expect(metadata.contentLanguage, 'en');
      expect(metadata.customMetadata, {'owner': 'alice'});
      verify(() => reference.getDownloadURL()).called(1);
    });
  }
}

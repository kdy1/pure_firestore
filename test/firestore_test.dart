import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:http/http.dart' as http;
import 'package:pure_firestore/pure_firestore.dart';

final db = PureFirestore(
  api: FirestoreApi(
    http.Client(),
    rootUrl: 'http://localhost:8080/',
  ),
  projectId: 'pure-firestore',
);

void main() {
  group('CollectionReference', () {
    test('get document with no permission', () async {
      expect(() => db.document('no/non-existent').get(), throwsA(anything));
    });

    test('get non existent document', () async {
      await db.document('ok/non-existent').get();
    });

    test('create document', () async {
      await db.collection('ok').add({
        'WTF': 'is this',
      });
    });

    test('create document with field value', () async {
      await db.collection('ok').add({
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  });
}

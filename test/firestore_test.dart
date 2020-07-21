import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pure_firestore/pure_firestore.dart';

final db = PureFirestore(
  client: http.Client(),
  rootUrl: 'http://localhost:8080/',
  projectId: 'pure-firestore',
);

void main() {
  initPureFirestore();

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
        'nested': {
          'depp': {
            'ok': true,
          },
          'why': "I'm lazy",
        }
      });
    });

    test('create document with field value', () async {
      await db.collection('ok').add({
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    test('create complex value', () async {
      await db.collection('ok').add({
        'parentId': 'parent-id-1',
        'title': 'Title',
        'category': 'extra',
        'seller': '나',
        'images': [],
        'products': [],
        'sendAt': Timestamp(1595350842, 372682000),
        'endAt': Timestamp(1595350842, 372620000),
        'createdAt': FieldValue.serverTimestamp(),
        'content': '<strong>Foo</strong>',
        'pm': {'m1': true, 'm2': false},
        'methods': {'m1': true, 'm2': true}
      });
    });
  });

  group('Query', () {
    test('can fetch documents', () async {
      for (int i = 0; i < 100; i++) {
        db.collection('ok').add({
          'value': i,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await db
          .collection('ok')
          .where('value', isGreaterThan: 70)
          .limit(30)
          .getDocuments();
    });
  });
}

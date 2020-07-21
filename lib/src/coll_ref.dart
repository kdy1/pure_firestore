import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:pure_firestore/pure_firestore.dart';
import 'package:pure_firestore/src/doc_ref.dart';
import 'package:pure_firestore/src/fields.dart';
import 'package:pure_firestore/src/query.dart';

class PureCollectionReference extends PureQuery implements CollectionReference {
  @override
  final String path;
  @override
  String get id => path.split('/').last;

  PureCollectionReference(PureFirestore firestore, this.path)
      : super(firestore, path);

  @override
  DocumentReference document([String path]) =>
      PureDocumentReference(firestore, '${this.path}/$path');

  @override
  DocumentReference parent() {
    final components = path.split('/');
    return PureDocumentReference(
      firestore,
      components.sublist(components.length - 1).join('/'),
    );
  }

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    final transforms = extractSpecialValues(data);
    final id = makeId(20);

    final doc = Document()
      ..name = '${firestore.docPath}/$path/$id'
      ..fields = data.map(
        (key, value) => MapEntry(
          key,
          serializeField(value),
        ),
      );

    final req = CommitRequest();
    req.writes = [
      Write()
        ..update = doc
        ..updateTransforms = transforms,
    ];

    await firestore.api.projects.databases.documents.commit(
      req,
      firestore.dbPath,
    );

    return PureDocumentReference(firestore, '$path/$id');
  }
}

String makeId(int i) {
  final rand = Random();
  final codeUnits = List.generate(i, (index) {
    return rand.nextInt(33) + 89;
  });

  return String.fromCharCodes(codeUnits);
}

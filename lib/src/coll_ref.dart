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
    final transform = extractSpecialValues(data);
    final doc = Document()
      ..fields = data.map(
        (key, value) => MapEntry(
          key,
          serializeField(value),
        ),
      );

    final req = CommitRequest();
    req.writes = [
      Write()..update = doc,
      if (transform != null) Write()..transform = transform,
    ];

    final result =
        await firestore.api.projects.databases.documents.createDocument(
      doc,
      path.contains('/')
          ? '${firestore.docPath}/${parent().path}'
          : '${firestore.docPath}',
      id,
    );

    final newPath = result.name.substring('${firestore.docPath}'.length);
    return PureDocumentReference(firestore, newPath);
  }
}

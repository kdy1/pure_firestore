import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:pure_firestore/pure_firestore.dart';
import 'package:pure_firestore/src/coll_ref.dart';
import 'package:pure_firestore/src/doc_snapshot.dart';
import 'package:pure_firestore/src/fields.dart';
import 'package:pure_firestore/src/snapshot_metadata.dart';

class PureDocumentReference implements DocumentReference {
  @override
  final PureFirestore firestore;
  @override
  final String path;

  PureDocumentReference(this.firestore, this.path);

  @override
  String get documentID => path.split('/').last;

  @override
  CollectionReference collection(String collectionPath) =>
      PureCollectionReference(
        firestore,
        '$path/$collectionPath',
      );

  @override
  CollectionReference parent() {
    final components = path.split('/');
    return PureCollectionReference(
      firestore,
      components.sublist(components.length - 1).join('/'),
    );
  }

  @override
  Future<DocumentSnapshot> get({
    Source source = Source.serverAndCache,
  }) async {
    try {
      final doc = await firestore.api.projects.databases.documents.get(
        '${firestore.docPath}/$path',
      );

      final data = parseFields(doc.fields);

      return PureDocumentSnapshot(
        data,
        this,
        PureSnapshotMetadata(
          isFromCache: false,
          hasPendingWrites: false,
        ),
      );
    } on DetailedApiRequestError catch (e) {
      if (e.status == 404) {
        return PureDocumentSnapshot(
          null,
          this,
          PureSnapshotMetadata(
            hasPendingWrites: false,
            isFromCache: false,
          ),
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> delete() async {
    await firestore.api.projects.databases.documents.delete(path);
  }

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    throw new UnimplementedError('DocumentReference.snapshots()');
  }

  @override
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) {
    return _set(
      data,
      merge: merge,
      precondition: null,
    );
  }

  @override
  Future<void> updateData(Map<String, dynamic> data) {
    return _set(
      data,
      merge: true,
      precondition: Precondition()..exists = true,
    );
  }

  Future<void> _set(
    Map<String, dynamic> data, {
    @required bool merge,
    @required Precondition precondition,
  }) async {
    final transforms = extractSpecialValues(data);
    final doc = Document()
      ..name = '${firestore.docPath}/$path'
      ..fields = data.map(
        (key, value) => MapEntry(
          key,
          serializeField(value),
        ),
      );

    final req = CommitRequest();
    req.writes = [
      Write()
        ..currentDocument = precondition
        ..update = doc
        ..updateTransforms = transforms,
    ];

    await firestore.api.projects.databases.documents
        .commit(req, firestore.dbPath);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pure_firestore/src/doc_ref.dart';
import 'package:pure_firestore/src/snapshot_metadata.dart';

class PureDocumentSnapshot implements DocumentSnapshot {
  @override
  final Map<String, dynamic> data;

  @override
  final PureDocumentReference reference;

  @override
  final PureSnapshotMetadata metadata;

  PureDocumentSnapshot(this.data, this.reference, this.metadata);

  @override
  bool get exists => data != null;

  @override
  String get documentID => reference.documentID;

  @override
  dynamic operator [](String key) {
    return data[key];
  }
}

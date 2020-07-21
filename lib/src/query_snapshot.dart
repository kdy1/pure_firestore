import 'package:cloud_firestore/cloud_firestore.dart';

class PureQuerySnapshot implements QuerySnapshot {
  final List<DocumentSnapshot> documents;

  PureQuerySnapshot(this.documents);

  @override
  List<DocumentChange> get documentChanges =>
      throw UnimplementedError('PureQuerySnapshot.documentChanges');

  @override
  SnapshotMetadata get metadata =>
      throw UnimplementedError('PureQuerySnapshot.metadata');
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PureSnapshotMetadata implements SnapshotMetadata {
  @override
  final bool hasPendingWrites;

  @override
  final bool isFromCache;

  PureSnapshotMetadata({
    @required this.hasPendingWrites,
    @required this.isFromCache,
  });
}

library pure_firestore;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:pure_firestore/src/coll_ref.dart';
import 'package:pure_firestore/src/doc_ref.dart';

/// This class exists for testing, so persistence is not implemented.
class PureFirestore implements Firestore {
  final FirestoreApi api;
  final String projectId;

  PureFirestore({
    @required this.api,
    @required this.projectId,
  });

  String get docPath => 'projects/$projectId/databases/(default)/documents';

  @override
  CollectionReference collection(String path) =>
      PureCollectionReference(this, path);

  @override
  DocumentReference document(String path) => PureDocumentReference(this, path);

  Future<void> settings({
    bool persistenceEnabled,
    String host,
    bool sslEnabled,
    int cacheSizeBytes,
  }) async {
    throw new UnimplementedError('PureFirestore.settings');
  }

  @override
  Future<void> enablePersistence(bool enable) async {
    throw new UnimplementedError('PureFirestore.enablePersistence');
  }

  @override
  FirebaseApp get app => throw UnimplementedError('PureFirestore.app');

  @override
  WriteBatch batch() {
    throw UnimplementedError('PureFirestore.batch');
  }

  @override
  Query collectionGroup(String path) {
    throw UnimplementedError('PureFirestore.collectionGroup');
  }

  @override
  Future<Map<String, dynamic>> runTransaction(
    TransactionHandler transactionHandler, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    throw UnimplementedError('PureFirestore.runTransaction');
  }
}

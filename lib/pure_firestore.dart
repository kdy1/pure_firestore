library pure_firestore;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:http/http.dart' as http;
import 'package:pure_firestore/src/coll_ref.dart';
import 'package:pure_firestore/src/doc_ref.dart';
import 'package:pure_firestore/src/field_value.dart';

/// This class exists for testing, so persistence is not implemented.
class PureFirestore implements Firestore {
  final FirestoreApi api;
  final String projectId;

  /// Should be authenticated. Required because of the bug of darg-lang/googleapis.
  ///
  /// See: https://github.com/dart-lang/googleapis/issues/25
  final http.Client client;
  final String rootUrl;

  PureFirestore({
    @required this.client,
    @required this.rootUrl,
    @required this.projectId,
  }) : api = FirestoreApi(
          client,
          rootUrl: rootUrl,
        );

  String get dbPath => 'projects/$projectId/databases/(default)';
  String get docPath => '$dbPath/documents';

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

void initPureFirestore() {
  platform.FieldValueFactoryPlatform.instance = PureFieldValueFactory();
}

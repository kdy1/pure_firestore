import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:pure_firestore/pure_firestore.dart';
import 'package:pure_firestore/src/coll_ref.dart';
import 'package:pure_firestore/src/fields.dart';

class PureQuery implements Query {
  @override
  final PureFirestore firestore;
  final String collectionPath;
  final _inner = RunQueryRequest();

  PureQuery(this.firestore, this.collectionPath);

  @override
  Query endAtDocument(DocumentSnapshot documentSnapshot) {
    throw new UnimplementedError('PureQuery.endAtDocument');
  }

  @override
  Query endBefore(List<dynamic> values) {
    throw new UnimplementedError('PureQuery.endBefore');
  }

  @override
  Query limit(int length) {
    _inner.structuredQuery.limit = length;
    return this;
  }

  @override
  CollectionReference reference() =>
      PureCollectionReference(firestore, collectionPath);

  @override
  Query endAt(List<dynamic> values) {
    _inner.structuredQuery.endAt = Cursor()
      ..values = values.map(serializeField).toList();
    return this;
  }

  @override
  Map<String, dynamic> buildArguments() {
    return _inner.structuredQuery.toJson();
  }

  @override
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) {
    throw new UnimplementedError('PureQuery.endBeforeDocument');
  }

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    throw new UnimplementedError('PureQuery.snapshots');
  }

  @override
  Query startAfter(List<dynamic> values) {
    throw new UnimplementedError('PureQuery.startAfter');
  }

  @override
  Query startAtDocument(DocumentSnapshot documentSnapshot) {
    throw new UnimplementedError('PureQuery.startAtDocument');
  }

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) {
    throw new UnimplementedError('PureQuery.startAfterDocument');
  }

  @override
  Query startAt(List<dynamic> values) {
    _inner.structuredQuery.startAt = Cursor()
      ..values = values.map(serializeField).toList();
    return this;
  }

  @override
  Query where(
    dynamic field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    List<dynamic> arrayContainsAny,
    List<dynamic> whereIn,
    bool isNull,
  }) {
    final filter = FieldFilter();
    if (isEqualTo != null) {
      filter
        ..op = 'EQUAL'
        ..value = serializeField(isEqualTo);
    } else if (isLessThan != null) {
      filter
        ..op = 'LESS_THAN'
        ..value = serializeField(isLessThan);
    } else if (isLessThanOrEqualTo != null) {
      filter
        ..op = 'LESS_THAN_OR_EQUAL'
        ..value = serializeField(isLessThanOrEqualTo);
    } else if (isGreaterThan != null) {
      filter
        ..op = 'GREATER_THAN'
        ..value = serializeField(isGreaterThan);
    } else if (isGreaterThanOrEqualTo != null) {
      filter
        ..op = 'GREATER_THAN_OR_EQUAL'
        ..value = isGreaterThanOrEqualTo;
    } else if (arrayContains != null) {
      filter
        ..op = 'ARRAY_CONTAINS'
        ..value = serializeField(arrayContains);
    } else if (arrayContainsAny != null) {
      filter
        ..op = 'ARRAY_CONTAINS_ANY'
        ..value = serializeField(arrayContainsAny);
    } else if (whereIn != null) {
      filter
        ..op = ''
        ..value = serializeField(whereIn);
    } else if (isNull != null) {
      filter
        ..op = 'EQUAL'
        ..value = serializeField(null);
    }

    _inner.structuredQuery.where.compositeFilter.filters ??= [];
    _inner.structuredQuery.where.compositeFilter.filters.add(
      Filter()..fieldFilter = filter,
    );
  }

  @override
  Query orderBy(
    dynamic field, {
    bool descending = false,
  }) {
    _inner.structuredQuery.orderBy.add(
      Order()
        ..field = field
        ..direction = descending ? 'DESCENDING' : 'ASCENDING',
    );

    return this;
  }

  @override
  Future<QuerySnapshot> getDocuments({
    Source source = Source.serverAndCache,
  }) async {
    final resp = await firestore.api.projects.databases.documents.runQuery(
      _inner,
      '${firestore.docPath}/$collectionPath',
    );

    debugPrint('${resp.toJson()}');
  }
}

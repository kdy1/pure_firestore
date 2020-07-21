import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:pure_firestore/pure_firestore.dart';
import 'package:pure_firestore/src/coll_ref.dart';
import 'package:pure_firestore/src/doc_ref.dart';
import 'package:pure_firestore/src/doc_snapshot.dart';
import 'package:pure_firestore/src/fields.dart';
import 'package:pure_firestore/src/query_snapshot.dart';
import 'package:pure_firestore/src/snapshot_metadata.dart';

class PureQuery implements Query {
  @override
  final PureFirestore firestore;
  final String collectionPath;
  final _inner = RunQueryRequest()..structuredQuery = StructuredQuery();

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
    final filter = FieldFilter()..field = (FieldReference()..fieldPath = field);
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
        ..op = 'IN'
        ..value = serializeField(whereIn);
    } else if (isNull != null) {
      filter
        ..op = 'EQUAL'
        ..value = serializeField(null);
    }

    _inner.structuredQuery.where ??= Filter();
    if (_inner.structuredQuery.where.fieldFilter == null) {
      _inner.structuredQuery.where.fieldFilter = filter;

      return this;
    }

    _inner.structuredQuery.where.compositeFilter ??= CompositeFilter();
    _inner.structuredQuery.where.compositeFilter.filters ??= <Filter>[
      Filter()..fieldFilter = _inner.structuredQuery.where.fieldFilter,
    ];
    _inner.structuredQuery.where.fieldFilter = null;
    _inner.structuredQuery.where.compositeFilter.filters.add(
      Filter()..fieldFilter = filter,
    );

    return this;
  }

  @override
  Query orderBy(
    dynamic field, {
    bool descending = false,
  }) {
    _inner.structuredQuery.orderBy ??= [];

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
    final components = collectionPath.split('/');
    final parentDoc = components.sublist(0, components.length - 1).join('/');
    _inner.structuredQuery.from = [
      CollectionSelector()..collectionId = components.last,
    ];
    final parent = parentDoc.isEmpty
        ? firestore.docPath
        : '${firestore.docPath}/${components.sublist(0, components.length - 1).join('/')}';

    final resp = await firestore.client.post(
      '${firestore.rootUrl}v1/$parent:runQuery',
      body: json.encode(_inner.toJson()),
    );

    final List<dynamic> list = json.decode(resp.body);
    final qs = list.map((e) => RunQueryResponse.fromJson(e));

    return PureQuerySnapshot(qs.map((ds) {
      //
      final data = parseFields(ds.document.fields);

      return PureDocumentSnapshot(
        data,
        PureDocumentReference(
          firestore,
          ds.document.name.substring(
            firestore.docPath.length,
          ),
        ),
        PureSnapshotMetadata(
          isFromCache: false,
          hasPendingWrites: false,
        ),
      );
    }).toList());
  }
}

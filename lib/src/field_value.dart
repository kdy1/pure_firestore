import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter/foundation.dart';

@immutable
class PureFieldValue {
  const PureFieldValue._();
}

class ArrayUnionFieldValue extends PureFieldValue {
  final List<dynamic> values;

  ArrayUnionFieldValue._(this.values) : super._();
}

class IncrementFieldValue extends PureFieldValue {
  final num value;

  IncrementFieldValue._(this.value) : super._();
}

class DeleteFieldValue extends PureFieldValue {
  DeleteFieldValue._() : super._();
}

class ServerTimestampFieldValue extends PureFieldValue {
  ServerTimestampFieldValue._() : super._();
}

class ArrayRemoveFieldValue extends PureFieldValue {
  final List<dynamic> values;

  ArrayRemoveFieldValue._(this.values) : super._();
}

class PureFieldValueFactory extends FieldValueFactoryPlatform {
  @override
  dynamic arrayUnion(List<dynamic> elements) =>
      ArrayUnionFieldValue._(elements);

  @override
  dynamic increment(num value) => IncrementFieldValue._(value);

  @override
  dynamic serverTimestamp() => ServerTimestampFieldValue._();

  @override
  dynamic delete() => DeleteFieldValue._();

  @override
  dynamic arrayRemove(List<dynamic> elements) =>
      ArrayRemoveFieldValue._(elements);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:pure_firestore/src/field_value.dart';

dynamic parseField(Value v) {
  if (v.nullValue == 'NULL_VALUE') return null;
  if (v.stringValue != null) return v.stringValue;
  if (v.integerValue != null) return v.integerValue;
  if (v.booleanValue != null) return v.booleanValue;
  if (v.doubleValue != null) return v.doubleValue;

  if (v.timestampValue != null) {
    return Timestamp.fromDate(DateTime.parse(v.timestampValue));
  }

  if (v.geoPointValue != null) {
    return GeoPoint(
      v.geoPointValue.latitude,
      v.geoPointValue.latitude,
    );
  }

  if (v.mapValue != null) {
    return parseFields(v.mapValue.fields);
  }

  if (v.arrayValue != null) {
    return v.arrayValue.values.map((v) => parseField(v)).toList();
  }

  throw new UnimplementedError('deserialization of $v}');
}

Map<String, dynamic> parseFields(Map<String, Value> fields) {
  final data = <String, dynamic>{};

  for (final entry in fields.entries) {
    final val = parseField(entry.value);
    data.addAll({entry.key: val});
  }

  return data;
}

Value serializeField(dynamic value) {
  if (value == null) {
    return Value()..nullValue = 'NULL_VALUE';
  }

  if (value is String) {
    return Value()..stringValue = value;
  }

  if (value is int) {
    return Value()..integerValue = value.toString();
  }

  if (value is bool) {
    return Value()..booleanValue = value;
  }

  if (value is double) {
    return Value()..doubleValue = value;
  }

  if (value is Map) {
    final val = MapValue()
      ..fields = value.map((key, value) {
        final v = serializeField(value);
        return MapEntry(key, v);
      });

    return Value()..mapValue = val;
  }

  if (value is Timestamp) {
    return Value()..timestampValue = value.toDate().toUtc().toIso8601String();
  }

  if (value is GeoPoint) {
    final geo = LatLng()
      ..latitude = value.latitude
      ..longitude = value.longitude;
    return Value()..geoPointValue = geo;
  }

  if (value is List) {
    final arr = ArrayValue()
      ..values = value.map((e) => serializeField(e)).toList();

    return Value()..arrayValue = arr;
  }

  throw new UnsupportedError('$value cannot be serialized for firestore');
}

Map<String, Value> serializeFields(Map<String, dynamic> data) {
  final res = <String, Value>{};
  for (final entry in data.entries) {
    final v = serializeField(entry.value);
    res.addAll({
      entry.key: v,
    });
  }

  return res;
}

List<FieldTransform> extractSpecialValues(Map<String, dynamic> data) {
  final transforms = <FieldTransform>[];

  bool visit(String path, dynamic v) {
    if (v is FieldValue) {
      // We found a special value
      final val = FieldValuePlatform.getDelegate(v);
      if (val is! PureFieldValue) {
        throw new StateError(
          'You should call initPureFirestore() to use FieldValues',
        );
      }

      if (val is PureFieldValue) {
        final tr = FieldTransform()..fieldPath = path;

        if (val is ArrayUnionFieldValue) {
          tr..appendMissingElements = serializeField(val.values) as ArrayValue;
        } else if (val is IncrementFieldValue) {
          tr..increment = serializeField(val.value);
        } else if (val is DeleteFieldValue) {
        } else if (val is ServerTimestampFieldValue) {
          tr..setToServerValue = 'REQUEST_TIME';
        } else if (val is ArrayRemoveFieldValue) {
          tr..removeAllFromArray = serializeField(val.values) as ArrayValue;
        }

        transforms.add(tr);

        return true;
      }
    }

    if (v is Map<String, dynamic>) {
      final removed = <String>[];
      for (final entry in v.entries) {
        final key = path.isEmpty ? entry.key : '$path.${entry.key}';

        if (visit(key, entry.value)) {
          removed.add(entry.key);
        }
      }
      for (final key in removed) {
        v.remove(key);
      }
      return false;
    }

    return false;
  }

  visit('', data);

  return transforms;
}

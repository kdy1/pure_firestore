import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/firestore/v1.dart';

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
        final map = MapValue()..fields = serializeFields(value);
        return MapEntry(key, Value()..mapValue = map);
      });

    return Value()..mapValue = val;
  }

  if (value is Timestamp) {
    return Value()..timestampValue = value.toDate().toIso8601String();
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
  final res = <String, dynamic>{};
  for (final entry in data.entries) {
    final v = serializeField(entry.value);
    res.addAll({
      entry.key: v,
    });
  }

  return res;
}

DocumentTransform extractSpecialValues(Map<String, dynamic> data) {
  final tr = DocumentTransform();
  void visit(String path, dynamic v) {
    if (v is Map<String, dynamic>) {
      for (final entry in v.entries) {
      }
    }
  }

  visit('', data);
}

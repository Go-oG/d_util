import 'package:uuid/uuid.dart';

abstract class IdUtil {

  static final _randomId = _RandomId();

  IdUtil._();

  static String idOf(Object? value, {bool nullAsEmpty = true}) {
    if (value == null) return nullAsEmpty ? "" : "NULL";
    if (value is String) return value;
    if (value is bool) return value ? "true" : "false";
    if (value is int) return value.toString();
    if (value is double) {
      if (value.isNaN) return "NaN";
      if (value.isInfinite) return value.isNegative ? "-Inf" : "Inf";
      if (value == 0.0) return "0";
      return value.toStringAsPrecision(12);
    }
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is List) {
      if (value.isEmpty) return "[]";
      return "[${value.map((e) => idOf(e, nullAsEmpty: nullAsEmpty)).join(',')}]";
    }
    if (value is Set) {
      if (value.isEmpty) return "[]";
      final list = value.toList();
      list.sort((a, b) => idOf(a, nullAsEmpty: nullAsEmpty).compareTo(idOf(b, nullAsEmpty: nullAsEmpty)));
      return idOf(list, nullAsEmpty: nullAsEmpty);
    }
    if (value is Map) {
      if (value.isEmpty) return "{}";
      final keys = value.keys.toList();
      keys.sort((a, b) => idOf(a, nullAsEmpty: nullAsEmpty).compareTo(idOf(b, nullAsEmpty: nullAsEmpty)));

      final b = StringBuffer("{");
      for (final k in keys) {
        b.write("${idOf(k, nullAsEmpty: nullAsEmpty)}:${idOf(value[k], nullAsEmpty: nullAsEmpty)},");
      }
      b.write("}");
      return b.toString();
    }
    return value.toString();
  }

  static String randomId() => _randomId.randomId();
}

final class _RandomId {
  final _uuid = Uuid();
  var _id = 0;

  String randomId() {
    _id++;
    return "${_uuid.v4().replaceAll("-", "")}$_id";
  }
}

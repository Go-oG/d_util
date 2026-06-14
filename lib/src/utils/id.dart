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
      if (value.isEmpty) return "list[]";
      return "list[${value.map((e) => _segment(e, nullAsEmpty)).join(',')}]";
    }
    if (value is Set) {
      if (value.isEmpty) return "set[]";
      final list = value.toList();
      list.sort(
        (a, b) => _segment(a, nullAsEmpty).compareTo(_segment(b, nullAsEmpty)),
      );
      return "set[${list.map((e) => _segment(e, nullAsEmpty)).join(',')}]";
    }
    if (value is Map) {
      if (value.isEmpty) return "map{}";
      final keys = value.keys.toList();
      keys.sort(
        (a, b) => _segment(a, nullAsEmpty).compareTo(_segment(b, nullAsEmpty)),
      );

      final b = StringBuffer("map{");
      for (final k in keys) {
        b.write(
          "${_segment(k, nullAsEmpty)}:${_segment(value[k], nullAsEmpty)},",
        );
      }
      b.write("}");
      return b.toString();
    }
    return value.toString();
  }

  static String randomId() => _randomId.randomId();

  static String _segment(Object? value, bool nullAsEmpty) {
    final id = idOf(value, nullAsEmpty: nullAsEmpty);
    return "${_tag(value)}${id.length}:$id";
  }

  static String _tag(Object? value) {
    if (value == null) return "n";
    if (value is String) return "s";
    if (value is bool) return "b";
    if (value is int) return "i";
    if (value is double) return "d";
    if (value is DateTime) return "t";
    if (value is List) return "l";
    if (value is Set) return "e";
    if (value is Map) return "m";
    return "o";
  }
}

final class _RandomId {
  final _uuid = Uuid();
  var _id = 0;

  String randomId() {
    _id++;
    return "${_uuid.v4().replaceAll("-", "")}$_id";
  }
}

import '../helper/num.dart';
import '../model/angle.dart';

extension NumberExt on num {
  static const _kAccuracy = 1e-9;

  bool equal(num other, [double accuracy = 1e-9]) {
    return (other - this).abs() <= accuracy;
  }

  int compare(num other, [double accurate = 1e-9]) {
    var sub = this - other;
    if (sub.abs() < accurate) {
      return 0;
    }
    if (sub > 0) {
      return 1;
    }
    return -1;
  }

  String format({int precision = 4, String infinityChar = "∞"}) {
    final value = this;
    if (value.isInfinite) {
      return value.isNegative ? "-$infinityChar" : infinityChar;
    }
    if (value.isNaN) {
      return 'NaN';
    }
    if (value == value.toInt() && value.abs() < _kAccuracy) {
      return value.toInt().toString();
    }

    if (value.abs() >= 1e15 || value.abs() <= 1e-15) {
      return value.toStringAsExponential(precision);
    }
    String s = value.toStringAsFixed(precision);
    var i = s.length;
    while (i > 0 && s[i - 1] == '0') {
      i--;
    }
    if (i > 0 && s[i - 1] == '.') i--;
    return s.substring(0, i);
  }

  Num get asFixedNum => Num.fixed(toDouble());

  Num get asPercentNum => Num.percent(toDouble());

  Angle get asRadians => Angle.radians(toDouble());

  Angle get asDegrees => Angle.degrees(toDouble());
}

extension IntExt on int {
  String padLeft(int width) {
    return toString().padLeft(width, '0');
  }

  String padRight(int width) {
    return toString().padRight(width, '0');
  }
}

num? asNum(Object? v, {bool allowDateTime = true}) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is DateTime && allowDateTime) {
    return v.millisecondsSinceEpoch;
  }
  if (v is String) return num.tryParse(v);

  return null;
}

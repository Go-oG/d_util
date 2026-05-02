import 'dart:math' as math;
import 'dart:ui';

import 'package:d_util/d_util.dart';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';

import '../types.dart';

final class _LerpFunGlobal {
  _LerpFunGlobal._();

  static Map<Type, Fun4<dynamic, dynamic, double, dynamic>> lerpFunSet = {};
}

void registerLerpFun<T>(Fun4<T, T, double, T> fun) {
  _LerpFunGlobal.lerpFunSet[T] = fun as Fun4<dynamic, dynamic, double, dynamic>;
}

void unregisterLerpFun<T>() {
  _LerpFunGlobal.lerpFunSet.remove(T);
}

T? lerpDynamic<T>(T s, T e, double t) {
  final funItem = _LerpFunGlobal.lerpFunSet[T];
  if (funItem != null) {
    return funItem(s, e, t);
  }
  if (s is num && e is num) {
    return lerpNum(s, e, t) as T;
  }

  if (s is Lerpable) {
    return s.lerpTo(e, t) as T;
  }

  if (s is Offset) {
    return lerpOffset(s, e as Offset, t) as T;
  }

  if (s is Size) {
    return lerpSize(s, e as Size, t) as T;
  }
  if (s is Rect) {
    return lerpRect(s, e as Rect, t) as T;
  }
  if (s is Color) {
    return Color.lerp(s, e as Color, t) as T;
  }

  if (s is Duration) {
    return lerpDuration(s, e as Duration, t) as T;
  }
  try {
    return (s as dynamic).lerp(e, t);
  } catch (_) {}
  try {
    return (s as dynamic) + ((e as dynamic) - (s as dynamic)) * t as T;
  } catch (_) {}
  return null;
}

Size lerpSize(Size? a, Size? b, double t) {
  if (a == b) {
    return b ?? Size.zero;
  }
  if (t == 0) {
    return a ?? Size.zero;
  }
  if (t == 1) {
    return b ?? Size.zero;
  }
  return Size.lerp(a, b, t)!;
}

Offset lerpOffset(Offset? a, Offset? b, double t) {
  if (a == b) {
    return b ?? Offset.zero;
  }
  if (t == 0) {
    return a ?? Offset.zero;
  }
  if (t == 1) {
    return b ?? Offset.zero;
  }
  return Offset.lerp(a, b, t)!;
}

Rect lerpRect(Rect? a, Rect? b, double t) {
  if (a == b) {
    return b ?? Rect.zero;
  }
  if (t == 0) {
    return a ?? Rect.zero;
  }
  if (t == 1) {
    return b ?? Rect.zero;
  }
  return Rect.lerp(a, b, t)!;
}

int lerpInt(int? s, int? e, double t) {
  if (s == e || (s?.isNaN ?? false) && (e?.isNaN ?? false)) {
    return s ?? 0;
  }
  s ??= 0;
  e ??= 0;
  return (s + (e - s) * t).round();
}

double lerpNum(num? s, num? e, double t) {
  if (s == e || (s?.isNaN ?? false) && (e?.isNaN ?? false)) {
    return s == null ? 0 : s.toDouble();
  }
  s ??= 0;
  e ??= 0;
  return (s + (e - s) * t);
}

List<Offset> lerpOffsetList(List<Offset> a, List<Offset> b, double t, {Offset dismissOffset = Offset.zero}) {
  final int maxLength = a.length > b.length ? a.length : b.length;
  final List<Offset> result = [];
  for (int i = 0; i < maxLength; i++) {
    final Offset start = i < a.length ? a[i] : (a.isNotEmpty ? a.last : dismissOffset);
    final Offset end = i < b.length ? b[i] : (b.isNotEmpty ? b.last : dismissOffset);
    result.add(Offset.lerp(start, end, t)!);
  }
  return result;
}

interface class Lerpable<T> {
  T lerpTo(T end, double factor) {
    throw UnimplementedError();
  }

  static T lerp<T extends Lerpable<T>>(T a, T b, double factor) {
    return a.lerpTo(b, factor);
  }
}

typedef LerpFun<T> = T Function(T start, T end, double t);

Object? lerpObject<T>(T? a, T? b, double t) {
  if (a == null && b == null) return null;

  if (T is num) {
    final v = lerpDouble(a as num?, b as num?, t)!;
    if (T is double) {
      return v;
    }
    return (v.toInt());
  }

  if (T is Offset) {
    return Offset.lerp(a as Offset?, b as Offset?, t);
  }

  if (T is Color) {
    return Color.lerp(a as Color?, b as Color?, t);
  }

  if (T is Size) {
    return Size.lerp(a as Size?, b as Size?, t);
  }

  if (T is Duration) {
    final s = (a as Duration?)?.inMilliseconds;
    final e = (b as Duration?)?.inMilliseconds;
    final v = lerpDouble(s, e, t)!.toInt();
    return Duration(milliseconds: v);
  }

  if (T is DateTime) {
    final s = (a as DateTime?)?.millisecondsSinceEpoch;
    final e = (b as DateTime?)?.millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch(lerpDouble(s, e, t)!.toInt());
  }

  if (T is Rect) {
    return Rect.lerp(a as Rect?, b as Rect?, t);
  }

  if (T is RRect) {
    return RRect.lerp(a as RRect?, b as RRect?, t);
  }

  if (a is Matrix4 && b is Matrix4) {
    return _lerpMatrix4(a as Matrix4?, b as Matrix4?, t);
  }

  if (T is List) {
    if (b == null) {
      return (a as List).map((e) => lerpObject(e, null, t)).toList();
    }
    if (a == null) {
      return (b as List).map((e) => lerpObject(null, e, t)).toList();
    }
    final len = (b as List).length;
    List result = [];
    for (int i = 0; i < len; i++) {
      final s = (i >= (a as List).length) ? null : (a as List)[i];
      final e = (b as List)[i];
      result.add(lerpObject(s, e, t));
    }
    return result;
  }

  if (T is Map) {
    final result = <dynamic, dynamic>{};
    if (b == null) {
      for (var e in (a as Map).entries) {
        result[e.key] = lerpObject(e.value, null, t);
      }
      return result;
    }
    if (a == null) {
      for (var e in (b as Map).entries) {
        result[e.key] = lerpObject(null, e.value, t);
      }
      return result;
    }
    for (var e in (b as Map).entries) {
      result[e.key] = lerpObject((a as Map)[e.key], e.value, t);
    }
    return result;
  }
  return t < 0.5 ? a : b;
}

Matrix4 _lerpMatrix4(Matrix4? a, Matrix4? b, double t) {
  if (a == null && b == null) {
    return Matrix4.identity();
  }
  final ta = Vector3.zero();
  final sa = Vector3.zero();
  final ra = Quaternion.identity();

  final tb = Vector3.zero();
  final sb = Vector3.zero();
  final rb = Quaternion.identity();

  a?.decompose(ta, ra, sa);
  b?.decompose(tb, rb, sb);

  final tTranslation = Vector3.zero();
  final tScale = Vector3.zero();

  Vector3.mix(ta, tb, t, tTranslation);
  Vector3.mix(sa, sb, t, tScale);

  final tRotation = _lerpQuaternion(ra, rb, t);

  return Matrix4.compose(tTranslation, tRotation, tScale);
}

Quaternion _lerpQuaternion(Quaternion a, Quaternion b, double t) {
  var cosHalfTheta = a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
  if (cosHalfTheta < 0.0) {
    b = Quaternion(-b.x, -b.y, -b.z, -b.w);
    cosHalfTheta = -cosHalfTheta;
  }
  if (cosHalfTheta > 0.9995) {
    final result = Quaternion(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
      a.z + (b.z - a.z) * t,
      a.w + (b.w - a.w) * t,
    );
    result.normalize();
    return result;
  }

  final halfTheta = math.acos(cosHalfTheta);
  final sinHalfTheta = math.sqrt(1.0 - cosHalfTheta * cosHalfTheta);

  final ratioA = math.sin((1 - t) * halfTheta) / sinHalfTheta;
  final ratioB = math.sin(t * halfTheta) / sinHalfTheta;

  final result = Quaternion(
    a.x * ratioA + b.x * ratioB,
    a.y * ratioA + b.y * ratioB,
    a.z * ratioA + b.z * ratioB,
    a.w * ratioA + b.w * ratioB,
  );
  result.normalize();
  return result;
}

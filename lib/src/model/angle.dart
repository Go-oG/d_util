import 'dart:math' as math;
import 'dart:ui';

extension AngleExt on num {

}

const pi2 = math.pi * 2;
const halfPi = math.pi * 0.5;
const piPow = math.pi * math.pi;

extension type Angle(double radians) implements double {
  static const _degToRad = math.pi / 180.0;
  static const _radToDeg = 180.0 / math.pi;

  static const zero = Angle.radians(0);
  static const full = Angle.radians(pi2);
  static const half = Angle.radians(math.pi);
  static const quarter = Angle.radians(halfPi);

  const Angle.radians(this.radians);

  const Angle.degrees(double degrees) : radians = degrees * _degToRad;

  double get degrees => radians * _radToDeg;

  Angle get normalized {
    if (radians >= 0 && radians <= pi2) {
      return this;
    }
    var value = radians % pi2;
    if (value < 0) value += pi2;
    return Angle.radians(value);
  }

  Angle rotate(Angle delta) => this + delta;

  Angle get inverse => -this;

  Angle get abs => radians < 0 ? Angle.radians(-radians) : this;

  Offset toVector(double length) => Offset(length * cos, length * sin);

  /// Linearly interpolates between two angles, taking the shortest arc.
  ///
  /// [t] in [0,1].
  static Angle lerp(Angle a, Angle b, double t) {
    final da = ((b.radians - a.radians + math.pi) % pi2) - math.pi;
    return Angle.radians(a.radians + da * t);
  }

  Angle operator +(Angle other) => Angle.radians(radians + other.radians);

  Angle add(num other, [bool otherIsDegrees = false]) {
    if (otherIsDegrees) {
      return Angle.degrees(degrees + other);
    }
    return Angle.radians(radians + other);
  }

  Angle operator -(Angle other) => Angle.radians(radians - other.radians);

  Angle sub(num other, [bool otherIsDegrees = false]) {
    if (otherIsDegrees) {
      return Angle.degrees(degrees - other);
    }
    return Angle.radians(radians - other);
  }

  Angle operator *(num factor) => Angle.radians(radians * factor);

  Angle multiply(num factor) => Angle.radians(radians * factor);

  Angle operator /(num factor) => Angle.radians(radians / factor);

  Angle div(num factor) => Angle.radians(radians / factor);

  Angle operator %(num factor) => Angle.radians(radians % factor);

  Angle operator -() => Angle.radians(-radians);

  bool operator <=(Angle other) => radians <= other.radians;

  bool operator >=(Angle other) => radians >= other.radians;

  bool operator <(Angle other) => radians < other.radians;

  bool operator >(Angle other) => radians > other.radians;

  double get sin => math.sin(radians);

  double get cos => math.cos(radians);

  double get tan => math.tan(radians);

  bool get isZero => radians.abs() <= 1e-9;

  bool get isFull => (radians - pi2).abs() <= 1e-9;

  bool equals(Angle other, [double epsilon = 1e-10]) => (radians - other.radians).abs() < epsilon;
}

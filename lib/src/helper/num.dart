import 'package:equatable/equatable.dart';

final class Num extends Equatable {
  static const zero = Num._(0, isPercent: false);
  static const half = Num.percent(0.5);
  static const full = Num.percent(1);
  final double value;
  final bool isPercent;

  const Num._(this.value, {this.isPercent = true});

  const Num.fixed(this.value) : isPercent = false;

  const Num.percent(this.value) : isPercent = true;

  Num copy({double? value, bool? isPercent}) {
    return Num._(value ?? this.value, isPercent: isPercent ?? this.isPercent);
  }

  double resolve(double size) => isPercent ? size * value : value;

  Num operator %(num other) => copy(value: value % other);

  Num operator *(num other) => copy(value: value * other);

  Num operator +(num other) => copy(value: value + other);

  Num operator -() => copy(value: -value);

  Num operator -(num other) => copy(value: value - other);

  Num operator /(num other) => copy(value: value / other);

  Num operator ~/(num other) => copy(value: (value ~/ other).toDouble());

  Num remainder(num other) => copy(value: value.remainder(other));

  bool operator <(Num other) => value < other.value;

  bool operator <=(Num other) => value <= other.value;

  bool operator >(Num other) => value > other.value;

  bool operator >=(Num other) => value >= other.value;

  int compareTo(num other) => value.compareTo(other);

  @override
  List<Object?> get props => [isPercent, value];
}

extension type const Normalized(double value) implements double {
  static const zero = Normalized(0);
  static const one = Normalized(1);
  static const half = Normalized(0.5);

  Normalized.clamped(double v) : value = v.clamp(0.0, 1.0);

  bool get isZero => (value - 0).abs() <= 1e-9;

  bool get isOne => (value - 1).abs() <= 1e-9;

  Normalized operator +(Normalized other) {
    return Normalized(value + other.value);
  }

  Normalized operator -(Normalized other) {
    return Normalized(value - other.value);
  }

  Normalized operator /(double other) {
    return Normalized(value / other);
  }
}

final class NormalizedOffset extends Equatable {
  final Normalized x;
  final Normalized y;

  const NormalizedOffset(this.x, this.y);

  NormalizedOffset.of(double x, double y) : x = Normalized(x), y = Normalized(y);

  Normalized get dx => x;

  Normalized get dy => y;

  @override
  List<Object?> get props => [x, y];
}

class NormalizedRange extends Equatable {
  static const full = NormalizedRange(Normalized(0), Normalized(1));
  static const zero = NormalizedRange(Normalized(0), Normalized(0));

  final Normalized begin;
  final Normalized end;

  const NormalizedRange(this.begin, this.end);

  NormalizedRange.of(double begin, double end) : begin = Normalized(begin), end = Normalized(end);

  Normalized get maxValue => begin.value > end.value ? begin : end;

  Normalized get minValue => begin.value < end.value ? begin : end;

  Normalized get start => begin;

  double get range => end - start;

  bool contains(double t, {double epsilon = 1e-9}) {
    return t >= (start.value - epsilon) && t <= (end.value + epsilon);
  }

  @override
  List<Object?> get props => [begin, end];

  @override
  String toString() {
    return "NormalizedRange:[$begin,$end]";
  }
}

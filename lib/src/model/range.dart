
import 'dart:math';

class Range<T extends num> {
  final T start;
  final T end;

  const Range(this.start, this.end);

  static List<Range<T>> mergeRanges<T extends num>(List<Range<T>> ranges) {
    if (ranges.isEmpty) return const [];

    final sorted = List<Range<T>>.from(ranges)..sort((a, b) => (a.start as num).compareTo(b.start as num));
    final List<Range<T>> result = [];
    var current = sorted.first;
    for (int i = 1; i < sorted.length; i++) {
      final next = sorted[i];
      if (current.canMerge(next)) {
        current = current.merge(next);
      } else {
        result.add(current);
        current = next;
      }
    }
    result.add(current);
    return result;
  }

  T get begin => start;

  T get range => (end - start) as T;

  T get maxValue => max(begin, end);

  T get minValue => min(begin, end);

  T clamp(T value) {
    if (value >= begin && value <= end) {
      return value;
    }
    return (value as num).clamp(begin, end) as T;
  }

  List<T> get asList => [minValue, maxValue];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Range<T> && runtimeType == other.runtimeType && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);

  T get length => (end - start) as T;

  bool overlaps(Range<T> other) {
    return !(end <= other.start || other.end <= start);
  }

  bool touches(Range<T> other) {
    return end == other.start || other.end == start;
  }

  bool canMerge(Range<T> other) {
    return overlaps(other) || touches(other);
  }

  Range<T> merge(Range<T> other) {
    return Range(start < other.start ? start : other.start, end > other.end ? end : other.end);
  }
}

typedef IntRange = Range<int>;

typedef DoubleRange = Range<double>;
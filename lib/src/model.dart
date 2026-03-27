final class Pair<F, S> {
  final F first;
  final S second;

  const Pair(this.first, this.second);

  @override
  int get hashCode {
    return Object.hash(first, second);
  }

  @override
  bool operator ==(Object other) {
    return other is Pair<F, S> && other.first == first && other.second == second;
  }
}

class Range<T extends num> {
  final T start;
  final T end;

  const Range(this.start, this.end);

  T get begin => start;

  T get range => (end - start) as T;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Range && runtimeType == other.runtimeType && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}

final class DoubleRange extends Range<double> {
  DoubleRange(super.start, super.end);
}

final class IntRange extends Range<int> {
  IntRange(super.start, super.end);
}

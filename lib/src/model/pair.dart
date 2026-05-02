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

final class Pair2<F, S, T> {
  final F first;
  final S second;
  final T third;

  const Pair2(this.first, this.second, this.third);

  @override
  int get hashCode {
    return Object.hash(first, second, third);
  }

  @override
  bool operator ==(Object other) {
    return other is Pair2<F, S, T> && other.first == first && other.second == second && other.third == third;
  }
}

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

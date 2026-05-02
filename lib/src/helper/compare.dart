typedef CompareFun<E> = int Function(E a, E b);

typedef CompareWith<K, E> = int Function(E element, K target);

typedef CompareFun2<E> = Comparable Function(E a);

abstract interface class CComparator<T> {
  int compare(T o1, T o2);
}

class CComparator2<T> implements CComparator<T> {
  final Comparator<T> comparator;

  CComparator2(this.comparator);

  @override
  int compare(T o1, T o2) {
    return comparator(o1, o2);
  }
}

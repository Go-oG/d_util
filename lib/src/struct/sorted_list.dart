import 'dart:collection';

class SortedList<E> extends IterableBase<E> {
  final List<E> _list = <E>[];
  final Comparator<E> _comparator;

  SortedList(this._comparator);

  UnmodifiableListView<E> get items => UnmodifiableListView(_list);

  @override
  Iterator<E> get iterator => _list.iterator;

  @override
  int get length => _list.length;

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  E get first => _list.first;

  @override
  E get last => _list.last;

  @override
  E get single => _list.single;

  E? get firstOrNull => _list.isEmpty ? null : _list.first;

  E? get lastOrNull => _list.isEmpty ? null : _list.last;

  E operator [](int index) => _list[index];

  Map<int, E> asMap() => _list.asMap();

  Iterable<E> getRange(int start, int end) => _list.getRange(start, end);

  List<E> sublist(int start, [int? end]) => _list.sublist(start, end);

  Iterable<E> get reversed => _list.reversed;

  @override
  List<E> toList({bool growable = true}) => _list.toList(growable: growable);

  @override
  Set<E> toSet() => _list.toSet();

  /// 返回第一个 >= value 的位置
  int lowerBound(E value) {
    var low = 0;
    var high = _list.length;
    while (low < high) {
      final mid = low + ((high - low) >> 1);
      if (_comparator(_list[mid], value) < 0) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }

  /// 返回第一个 > value 的位置
  int upperBound(E value) {
    var low = 0;
    var high = _list.length;
    while (low < high) {
      final mid = low + ((high - low) >> 1);
      if (_comparator(_list[mid], value) <= 0) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }

  void add(E value) {
    final index = upperBound(value);
    _list.insert(index, value);
  }

  void addAll(Iterable<E> values) {
    for (final value in values) {
      add(value);
    }
  }

  void clear() => _list.clear();

  @override
  bool contains(Object? element) => _list.contains(element);

  int indexOf(E element, [int start = 0]) => _list.indexOf(element, start);

  int lastIndexOf(E element, [int? start]) => _list.lastIndexOf(element, start);

  int indexWhere(bool Function(E element) test, [int start = 0]) {
    return _list.indexWhere(test, start);
  }

  int lastIndexWhere(bool Function(E element) test, [int? start]) {
    return _list.lastIndexWhere(test, start);
  }

  bool remove(E value) => _list.remove(value);

  E removeAt(int index) => _list.removeAt(index);

  E removeLast() => _list.removeLast();

  void removeRange(int start, int end) => _list.removeRange(start, end);

  void removeWhere(bool Function(E element) test) => _list.removeWhere(test);

  void retainWhere(bool Function(E element) test) => _list.retainWhere(test);

  @override
  String toString() => _list.toString();
}

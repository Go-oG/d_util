import 'package:d_util/d_util.dart';

class SortedList<E> extends Iterable<E> {
  final List<E> _list = [];
  final Comparator<E> _comparator;

  SortedList(this._comparator);

  List<E> get items => List.unmodifiable(_list);

  @override
  Iterator<E> get iterator => _list.iterator;

  @override
  bool any(bool Function(E element) test) => _list.any(test);

  @override
  bool contains(Object? element) => _list.contains(element);

  @override
  E elementAt(int index) => _list.elementAt(index);

  @override
  bool every(bool Function(E element) test) => _list.every(test);

  @override
  get first => _list.first;

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) => _list.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) => _list.fold(initialValue, combine);

  @override
  Iterable<E> followedBy(Iterable<E> other) => _list.followedBy(other);

  @override
  void forEach(void Function(E element) action) => _list.forEach(action);

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String join([String separator = ""]) => _list.join(separator);

  @override
  E get last => _list.last;

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) => _list.lastWhere(test, orElse: orElse);

  @override
  int get length => _list.length;

  @override
  Iterable<T> map<T>(T Function(E e) toElement) => _list.map(toElement);

  @override
  E reduce(E Function(E value, E element) combine) => _list.reduce(combine);

  @override
  E get single => _list.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) => _list.singleWhere(test, orElse: orElse);

  @override
  Iterable<E> skip(int count) => _list.skip(count);

  @override
  Iterable<E> skipWhile(bool Function(E value) test) => _list.skipWhile(test);

  @override
  Iterable<E> take(int count) => _list.take(count);

  @override
  Iterable<E> takeWhile(bool Function(E value) test) => _list.takeWhile(test);

  @override
  List<E> toList({bool growable = true}) => _list.toList(growable: growable);

  @override
  Set<E> toSet() => _list.toSet();

  @override
  Iterable<E> where(bool Function(E element) test) => _list.where(test);

  @override
  Iterable<T> whereType<T>() => _list.whereType();

  List<E> operator +(List<E> other) => _list + other;

  E operator [](int index) => _list[index];

  void addAll(Iterable<E> iterable) {
    for (var value in iterable) {
      add(value);
    }
  }

  Map<int, E> asMap() => _list.asMap();

  void clear() => _list.clear();

  Iterable<E> getRange(int start, int end) => _list.getRange(start, end);

  int indexOf(E element) {
    return _list.findIndex(element, _comparator);
  }

  int indexWhere(bool Function(E element) test, [int start = 0]) => _list.indexWhere(test, start);

  int lastIndexOf(E element, [int? start]) => _list.lastIndexOf(element, start);

  int lastIndexWhere(bool Function(E element) test, [int? start]) => _list.lastIndexWhere(test, start);

  E removeAt(int index) => _list.removeAt(index);

  E removeLast() {
    return removeAt(_list.length - 1);
  }

  void removeRange(int start, int end) {
    for (var i = start; i < end; i++) {
      removeAt(i);
    }
  }

  void removeWhere(bool Function(E element) test) => _list.removeWhere(test);

  void retainWhere(bool Function(E element) test) => _list.retainWhere(test);

  Iterable<E> get reversed => _list.reversed;

  List<E> sublist(int start, [int? end]) => _list.sublist(start, end);

  @override
  List<R> cast<R>() => _list.cast();

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) => _list.expand(toElements);

  void add(E value) {
    final index =_list.findInsertIndex(value, _comparator);
    _list.insert(index, value);
  }

  bool remove(E value) => _list.remove(value);
  
}

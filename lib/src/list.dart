import 'dart:math';

enum ConflictAlg { dropOld, dropNew }

///它在保证唯一性的同时额外记录了索引信息
class UniqueList<E> implements Iterable<E> {
  late final ConflictAlg alg;
  final Map<E, int> _set = {};
  final List<E> _list = [];

  UniqueList([this.alg = ConflictAlg.dropNew]);

  @override
  bool any(bool Function(E element) test) => _list.any(test);

  @override
  bool contains(Object? element) => _set.containsKey(element);

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
  Iterator<E> get iterator => _list.iterator;

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

  void operator []=(int index, E value) => insert(index, value);

  void add(E value) {
    insert(_list.length, value);
  }

  void addAll(Iterable<E> iterable) {
    for (var value in iterable) {
      add(value);
    }
  }

  Map<int, E> asMap() => _list.asMap();

  void clear() {
    _list.clear();
    _set.clear();
  }

  Iterable<E> getRange(int start, int end) => _list.getRange(start, end);

  int indexOf(E element, [int start = 0]) {
    final index = _set[element];
    if (index == null || index < start) {
      return -1;
    }
    return index;
  }

  int indexWhere(bool Function(E element) test, [int start = 0]) => _list.indexWhere(test, start);

  bool insert(int index, E element) {
    if (!_set.containsKey(element)) {
      _list.insert(index, element);
      _set[element] = index;
      for (var i = index + 1; i < _list.length; i++) {
        _set[_list[i]] = i;
      }
      return true;
    }
    if (alg == ConflictAlg.dropNew) {
      return false;
    }
    int oldIndex = _list.indexOf(element);
    if (oldIndex == index) {
      _list[index] = element;
      _set[element] = index;
      return true;
    }

    _list.remove(oldIndex);
    for (var i = oldIndex; i < _list.length; i++) {
      _set[_list[i]] = i;
    }

    _list.insert(index, element);

    for (var i = index; i < _list.length; i++) {
      _set[_list[i]] = i;
    }

    return true;
  }

  void insertAll(int index, Iterable<E> values) {
    var startIndex = index;
    for (var value in values) {
      if (insert(startIndex, value)) {
        startIndex++;
      }
    }
  }

  int lastIndexOf(E element, [int? start]) => _list.lastIndexOf(element, start);

  int lastIndexWhere(bool Function(E element) test, [int? start]) => _list.lastIndexWhere(test, start);

  bool remove(Object? value) {
    if (_set.remove(value) != null) {
      return _list.remove(value);
    }
    return false;
  }

  E removeAt(int index) {
    final e = _list.removeAt(index);
    _set.remove(e);
    return e;
  }

  E removeLast() {
    return removeAt(_list.length - 1);
  }

  void removeRange(int start, int end) {
    for (var i = start; i < end; i++) {
      removeAt(i);
    }
  }

  void removeWhere(bool Function(E element) test) {
    _list.removeWhere(test);
    _set.removeWhere((k, v) => test(k));
  }

  void retainWhere(bool Function(E element) test) => _list.retainWhere(test);

  Iterable<E> get reversed => _list.reversed;

  void shuffle([Random? random]) {
    _list.shuffle(random);
    _adjustIndex();
  }

  void sort([int Function(E a, E b)? compare]) {
    _list.sort(compare);
    _adjustIndex();
  }

  List<E> sublist(int start, [int? end]) => _list.sublist(start, end);

  void _adjustIndex() {
    int i = 0;
    for (var item in _list) {
      _set[item] = i;
      i++;
    }
  }

  @override
  List<R> cast<R>() => _list.cast();

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) => _list.expand(toElements);

  @override
  String toString() {
    return _list.toString();
  }
}
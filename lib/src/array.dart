import 'dart:math';

import 'math.dart';
import 'types.dart';

final class Array<E> implements List<E> {
  late final List<dynamic> _list;

  final int size;

  static Array<T> list<T>(Iterable<T> list) {
    final size = list.length;
    var array = Array<T>(size);
    var i = 0;
    for (var e in list) {
      array[i] = e;
      i++;
    }
    return array;
  }

  static Array<T> of<T>(T data) {
    return list([data]);
  }

  static Array<Array<T>> matrix<T>(int size) {
    var array = Array<Array<T>>(size);
    for (var i = 0; i < size; i++) {
      array[i] = Array(size);
    }
    return array;
  }

  static Array<Array<T>> matrix2<T>(int rowCount, int colCount) {
    var array = Array<Array<T>>(rowCount);
    for (var i = 0; i < rowCount; i++) {
      array[i] = Array(colCount);
    }
    return array;
  }

  Array([this.size = 0]) {
    if (E is int) {
      _list = List.filled(size, 0);
    } else if (E is double) {
      _list = List.filled(size, 0.0);
    } else if (E is num) {
      _list = List.filled(size, 0.0);
    } else if (E is bool) {
      _list = List.filled(size, false);
    } else {
      _list = List.filled(size, null);
    }
  }

  @override
  E operator [](int index) => _list[index] as E;

  E? get(int index) => _list[index] as E?;

  @override
  void operator []=(int index, E? value) => _list[index] = value;

  List<E> asList() {
    List<E> list = [];
    for (var item in _list) {
      if (item == null) {
        throw "参数错误";
      }
      list.add(item);
    }
    return list;
  }

  @override
  Iterable<E> get reversed => _list.reversed.cast();

  @override
  void sort([int Function(E a, E b)? compare]) {
    if (compare != null) {
      _list.sort((a, b) => compare(a, b));
    } else {
      _list.sort();
    }
  }

  void sort2(CComparator<E> comparator) {
    sort((a, b) => comparator.compare(a, b));
  }

  void each(void Function(E, int) call) {
    var i = 0;
    for (var e in _list) {
      call(e, i);
      i++;
    }
  }

  void eachCast<T>(void Function(T, int) call) {
    var i = 0;
    for (var e in _list) {
      call(e as T, i);
      i++;
    }
  }

  Array<T> asArray<T>() {
    var array = Array<T>(size);
    int i = 0;
    for (var item in _list) {
      array[i] = item as T;
      i++;
    }
    return array;
  }

  Array<E> copy() {
    var array = Array<E>(size);
    int i = 0;
    for (var item in _list) {
      array[i] = item;
      i++;
    }
    return array;
  }

  @override
  int get length => size;

  @override
  E get first => _list[0];

  @override
  E get last => _list[size - 1];

  @override
  set first(E value) {
    _list[0] = value;
  }

  @override
  set last(E value) {
    _list[size - 1] = value;
  }

  @override
  List<E> operator +(List<E> other) => throw UnimplementedError();

  @override
  void add(E value) => throw UnimplementedError();

  @override
  void addAll(Iterable<E> iterable) => throw UnimplementedError();

  @override
  bool any(bool Function(E element) test) {
    return _list.any((e) => test(e));
  }

  @override
  Map<int, E> asMap() {
    final Map<int, E> map = {};
    var index = 0;
    for (var item in _list) {
      map[index] = item;
      index++;
    }
    return map;
  }

  @override
  void clear() {
    for (var i = 0; i < size; i++) {
      if (E is int) {
        _list[i] = 0;
      } else if (E is num) {
        _list[i] = 0.0;
      } else if (E is bool) {
        _list[i] = false;
      } else {
        _list[i] = null;
      }
    }
  }

  @override
  bool contains(Object? element) => _list.contains(element);

  @override
  E elementAt(int index) => _list[index];

  @override
  bool every(bool Function(E element) test) => _list.every((e) => test(e));

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) => throw UnimplementedError();

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    _list.fillRange(start, end, fillValue);
  }

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    return _list.firstWhere((e) => test(e), orElse: orElse);
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    return _list.fold(initialValue, (acc, e) => combine(acc, e));
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) => throw UnimplementedError();

  @override
  void forEach(void Function(E element) action) {
    for (var e in _list) {
      action(e);
    }
  }

  @override
  Iterable<E> getRange(int start, int end) {
    return _list.getRange(start, end).cast();
  }

  @override
  int indexOf(E element, [int start = 0]) {
    return _list.indexOf(element, start);
  }

  @override
  int indexWhere(bool Function(E element) test, [int start = 0]) {
    return _list.indexWhere((e) => test(e), start);
  }

  @override
  void insert(int index, E element) {
    _list[index] = element;
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {}

  @override
  bool get isEmpty => throw UnimplementedError();

  @override
  bool get isNotEmpty => throw UnimplementedError();

  @override
  Iterator<E> get iterator => throw UnimplementedError();

  @override
  String join([String separator = ""]) {
    return _list.join(separator);
  }

  @override
  int lastIndexOf(E element, [int? start]) {
    return _list.lastIndexOf(element, start);
  }

  @override
  int lastIndexWhere(bool Function(E element) test, [int? start]) {
    return _list.lastIndexWhere((e) => test(e), start);
  }

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    return _list.lastWhere((e) => test(e), orElse: orElse);
  }

  @override
  set length(int newLength) {
    throw UnimplementedError();
  }

  @override
  Iterable<T> map<T>(T Function(E e) toElement) {
    return _list.map((e) => toElement(e));
  }

  @override
  E reduce(E Function(E value, E element) combine) {
    return _list.reduce((v, e) => combine(v, e));
  }

  @override
  bool remove(Object? value) => throw UnimplementedError();

  @override
  E removeAt(int index) => throw UnimplementedError();

  @override
  E removeLast() => throw UnimplementedError();

  @override
  void removeRange(int start, int end) => throw UnimplementedError();

  @override
  void removeWhere(bool Function(E element) test) => throw UnimplementedError();

  @override
  void replaceRange(int start, int end, Iterable<E> replacements) => throw UnimplementedError();

  @override
  void retainWhere(bool Function(E element) test) {
    return _list.retainWhere((e) => test(e));
  }

  @override
  void setAll(int index, Iterable<E> iterable) {
    _list.setAll(index, iterable);
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _list.setRange(start, end, iterable, skipCount);
  }

  @override
  void shuffle([Random? random]) {
    return _list.shuffle(random);
  }

  @override
  E get single => _list.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    return _list.singleWhere((e) => test(e), orElse: orElse);
  }

  @override
  Iterable<E> skip(int count) {
    return _list.skip(count).cast();
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    return _list.skipWhile((e) => test(e)).cast();
  }

  @override
  List<E> sublist(int start, [int? end]) {
    return _list.sublist(start, end).cast();
  }

  @override
  Iterable<E> take(int count) {
    return _list.take(count).cast();
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    return _list.takeWhile((e) => test(e)).cast();
  }

  @override
  List<E> toList({bool growable = true}) {
    return _list.cast();
  }

  @override
  Set<E> toSet() {
    return _list.toSet().cast();
  }

  @override
  Iterable<E> where(bool Function(E element) test) {
    return _list.where((e) => test(e)).cast();
  }

  @override
  Iterable<T> whereType<T>() {
    return _list.whereType<T>();
  }

  @override
  List<R> cast<R>() {
    List<R> resultList = [];
    for (var item in _list) {
      if (E is num) {
        if (R is int) {
          resultList.add((item as num).toInt() as R);
        } else {
          resultList.add((item as num).toDouble() as R);
        }
      } else {
        resultList.add(item as R);
      }
    }
    return resultList;
  }

  static void sortRange<T>(Array<T> array, int fromIndex, int toIndex, [int Function(T a, T b)? comparator]) {
    if (fromIndex < 0 || toIndex > array.length || fromIndex > toIndex) {
      throw RangeError("Invalid range: $fromIndex to $toIndex");
    }
    var sublist = array._list.sublist(fromIndex, toIndex);
    if (comparator != null) {
      sublist.sort((a, b) => comparator(a as T, b as T));
    } else {
      if (sublist.isNotEmpty && sublist.first is Comparable) {
        (sublist as List<Comparable>).sort();
      } else {
        throw ArgumentError("List elements must be Comparable if no comparator is provided");
      }
    }
    array._list.setRange(fromIndex, toIndex, sublist);
  }

  static Array<T> copyOf<T>(Array<T> original, int newLength) {
    Array<T> copy = Array(newLength);
    arrayCopy(original, 0, copy, 0, Math.min(original.length, newLength).toInt());
    return copy;
  }

  static void arrayCopy<T>(Array<T> src, int srcPos, Array<T> dest, int destPos, int length) {
    if (srcPos < 0 || destPos < 0 || length < 0 || srcPos + length > src.length || destPos + length > dest.length) {
      throw RangeError("Invalid source or destination position or length");
    }
    dest._list.setRange(destPos, destPos + length, src._list, srcPos);
  }

  static int binarySearch<T>(Array<T> a, int fromIndex, int toIndex, T key) {
    int low = fromIndex;
    int high = toIndex - 1;

    while (low <= high) {
      int mid = (low + high) >>> 1;
      T midVal = a[mid];

      int c = (midVal as Comparable).compareTo(key);

      if (c < 0) {
        low = mid + 1;
      } else if (c > 0) {
        high = mid - 1;
      } else {
        return mid;
      }
    }
    return -(low + 1);
  }


}

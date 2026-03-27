import '../struct/array.dart';
import '../types.dart';

extension IterableExt<E> on Iterable<E> {
  Array<E> toArray() {
    var array = Array<E>(length);
    var i = 0;
    for (var item in this) {
      array[i] = item;
      i++;
    }
    return array;
  }

  void each(EachFun<E> fun) {
    int index = 0;
    for (var item in this) {
      fun(item, index);
      index++;
    }
  }

  E? minBy(CompareFun<E> compare) {
    E? minV;
    for (var item in this) {
      if (minV == null) {
        minV = item;
      } else {
        var c = compare(item, minV);
        if (c < 0) {
          minV = item;
        }
      }
    }
    return minV;
  }

  E? maxBy(CompareFun<E> compare) {
    E? maxV;
    for (var item in this) {
      if (maxV == null) {
        maxV = item;
      } else {
        var c = compare(item, maxV);
        if (c > 0) {
          maxV = item;
        }
      }
    }
    return maxV;
  }

  List<E> extreme(CompareFun<E> compare) {
    if (isEmpty) {
      return [];
    }

    List<E> list = [];
    E? minV;
    E? maxV;
    for (var item in this) {
      if (minV == null) {
        minV = item;
      } else {
        var c = compare(minV, item);
        if (c > 0) {
          minV = item;
        }
      }

      if (maxV == null) {
        maxV = item;
      } else {
        var c = compare(maxV, item);
        if (c < 0) {
          maxV = item;
        }
      }
    }
    return list;
  }

  double sum(double Function(E) sumFun, {double initValue = 0}) {
    double sum = initValue;
    for (var item in this) {
      sum += sumFun(item);
    }
    return sum;
  }

  void checkEmpty() {
    if (isEmpty) {
      throw StateError("Cannot find minimum of empty collection");
    }
  }

  Set<E> toSet([bool copySelf = true]) {
    if (this is Set) {
      if (copySelf) {
        return Set.from(this);
      }
      return this as Set<E>;
    }
    return Set.from(this);
  }

  List<E> toList([bool copySelf = true]) {
    if (this is List) {
      if (copySelf) {
        return List.from(this);
      }
      return this as List<E>;
    }
    return List.from(this);
  }

  ///返回一个按顺序排列的唯一值的List
  List<E> union() {
    return unionBy<E>((p0) => p0);
  }

  List<E> unionBy<K>(K? Function(E) convert) {
    List<E> rl = [];
    Set<K?> set = {};
    for (var v in this) {
      var k = convert(v);
      if (set.contains(k)) {
        continue;
      }
      rl.add(v);
      set.add(k);
    }
    return rl;
  }

  Map<E, K> keyMap<K>(K Function(E key, int index) valueFun) {
    Map<E, K> map = {};
    int index = 0;
    for (var item in this) {
      map[item] = valueFun(item, index);
      index++;
    }
    return map;
  }

  Map<V, E> valueMap<V>(V Function(E key, int index) keyFun) {
    Map<V, E> map = {};
    int index = 0;
    for (var item in this) {
      map[keyFun(item, index)] = item;
      index++;
    }
    return map;
  }
}

extension ListExt<E> on List<E> {
  void set(int index, E value) => this[index] = value;

  E get(int index) => this[index];

  E? getOrNull(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return this[index];
  }

  int get size => length;

  void sortWith(CComparator<E> comparator) {
    sort((a, b) => comparator.compare(a, b));
  }

  void removeAll(Iterable<E> elements) {
    for (var e in elements) {
      remove(e);
    }
  }

  ListIterator<E> listIterator([int index = 0]) {
    return ListIterator(this, index);
  }

  void eachRight(EachFun<E> fun) {
    int index = length - 1;
    for (var item in reversed) {
      fun(item, index);
      index++;
    }
  }

  void reduplicate() {
    if (length <= 1) {
      return;
    }
    Set<E> unionSet = <E>{};
    int i = 0;
    while (i < length) {
      var e = this[i];
      if (unionSet.contains(e)) {
        removeAt(i);
      } else {
        i++;
      }
    }
  }

  E? removeLastOrNull() {
    if (isEmpty) {
      return null;
    }
    return removeLast();
  }

  E? removeFirstOrNull() {
    if (isEmpty) {
      return null;
    }
    return removeAt(0);
  }

  void reverseSelf() {
    int left = 0;
    int right = length - 1;
    while (left < right) {
      final temp = this[left];
      this[left] = this[right];
      this[right] = temp;
      left++;
      right--;
    }
  }

  List<E> toUnionList() {
    Set<E> unionSet = <E>{};
    List<E> list = [];
    for (var item in this) {
      if (unionSet.contains(item)) {
        continue;
      }
      list.add(item);
      unionSet.add(item);
    }
    return list;
  }

  void sortBy(CompareFun2<E> compare) {
    sort((a, b) => compare(a).compareTo(compare(b)));
  }

  List<E> slice([int start = 0, int? end]) {
    return sublist(start, end);
  }

  E pop() {
    return removeLast();
  }

  void push(E value) {
    insert(0, value);
  }

  List<E> copy() => List.from(this);

  /// 第一个 >= target 的位置
  /// 如果不存在，则返回 length
  int lowerBound<K>(K target, CompareWith<K, E> compare) {
    int low = 0;
    int high = length;
    while (low < high) {
      final mid = low + ((high - low) >> 1);
      if (compare(this[mid], target) < 0) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }

  /// 第一个 > target 的位置
  /// 如果不存在，则返回 length
  int upperBound<K>(K target, CompareWith<K, E> compare) {
    int low = 0;
    int high = length;
    while (low < high) {
      final mid = low + ((high - low) >> 1);
      if (compare(this[mid], target) <= 0) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }

  /// 二分查找等于 target 的元素位置
  /// 没找到返回 [notFound]
  int binarySearchIndex<K>(K target, CompareWith<K, E> compare, [int notFound = -1]) {
    if (isEmpty) {
      return notFound;
    }
    final index = lowerBound(target, compare);
    if (index < length && compare(this[index], target) == 0) {
      return index;
    }
    return notFound;
  }

  /// 最后一个 < target 的元素位置
  /// 没有则返回 [notFound]
  int lastLessThanIndex<K>(K target, CompareWith<K, E> compare, [int notFound = -1]) {
    if (isEmpty) {
      return notFound;
    }
    final index = lowerBound(target, compare) - 1;
    return index >= 0 ? index : notFound;
  }
}

class ListIterator<T> {
  final List<T> _list;
  int _cursor;
  int _lastRet = -1;

  ListIterator(this._list, [int index = 0]) : _cursor = index {
    if (index < 0 || index > _list.length) {
      throw RangeError('index: $index');
    }
  }

  bool hasNext() => _cursor < _list.length;

  T next() {
    if (!hasNext()) {
      throw StateError('No such element');
    }
    _lastRet = _cursor;
    return _list[_cursor++];
  }

  bool hasPrevious() => _cursor > 0;

  T previous() {
    if (!hasPrevious()) {
      throw StateError('No such element');
    }
    _lastRet = --_cursor;
    return _list[_cursor];
  }

  int nextIndex() => _cursor;

  int previousIndex() => _cursor - 1;

  void remove() {
    if (_lastRet == -1) {
      throw StateError('Invalid state');
    }
    _list.removeAt(_lastRet);
    if (_lastRet < _cursor) {
      _cursor--;
    }
    _lastRet = -1;
  }

  void set(T element) {
    if (_lastRet == -1) {
      throw StateError('Invalid state');
    }
    _list[_lastRet] = element;
  }

  void add(T element) {
    _list.insert(_cursor, element);
    _cursor++;
    _lastRet = -1;
  }
}

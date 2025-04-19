import 'array.dart';
import 'types.dart';

extension IterableExt<E> on Iterable<E> {
  Array<E> toArray() {
    var array = Array<E>(length);
    var i = 0;
    for (var item in this) {
      array[i] = item;
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

  E min(CompareFun<E> compare) {
    _checkEmpty();

    E? minV;
    for (var item in this) {
      if (minV == null) {
        minV = item;
      } else {
        var c = compare(minV, item);
        if (c > 0) {
          minV = item;
        }
      }
    }
    return minV!;
  }

  E minBy(CompareFun2<E> compare) {
    _checkEmpty();
    E? minV;
    for (var item in this) {
      if (minV == null) {
        minV = item;
      } else {
        final a = compare(item);
        final b = compare(minV);
        var c = a.compareTo(b);
        if (c < 0) {
          minV = item;
        }
      }
    }
    return minV!;
  }

  E max(CompareFun<E> compare) {
    _checkEmpty();
    E? maxV;
    for (var item in this) {
      if (maxV == null) {
        maxV = item;
      } else {
        var c = compare(maxV, item);
        if (c < 0) {
          maxV = item;
        }
      }
    }
    return maxV!;
  }

  E maxBy(CompareFun2<E> compare) {
    _checkEmpty();
    E? maxV;
    for (var item in this) {
      if (maxV == null) {
        maxV = item;
      } else {
        final a = compare(item);
        final b = compare(maxV);
        var c = a.compareTo(b);
        if (c > 0) {
          maxV = item;
        }
      }
    }
    return maxV!;
  }

  List<E> extreme(CompareFun<E> compare) {
    _checkEmpty();

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

  void _checkEmpty() {
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
}

extension ListExt<E> on List<E> {
  void set(int index, E value) => this[index] = value;

  E get(int index) => this[index];

  int get size => length;

  void sort2(CComparator<E> comparator) {
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
    ///TODO使用更高效算法
    List<E> rl = List.from(reversed);
    clear();
    addAll(rl);
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

  ///找到插入位置,调用该方法时List必须为已排序
  int findInsertIndex(E data, CompareFun<E> compare) {
    if (isEmpty) {
      return 0;
    }
    int left = 0;
    int right = length - 1;
    int mid = 0;
    while (left < right) {
      mid = left + (right - left) ~/ 2;
      final md = this[mid];
      int c = compare(data, md);
      if (c == 0) {
        return mid;
      }
      if (c > 0) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }
    return left;
  }

  ///找到数据位置,List 必须为已排序
  ///没找到返回-1
  int findIndex(E value, CompareFun<E> compare) {
    int left = 0;
    int right = length;
    while (left < right) {
      final int mid = left + ((right - left) >> 1);
      final element = this[mid];
      final int comp = compare(element, value);
      if (comp == 0) {
        return mid;
      }
      if (comp < 0) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }
    return -1;
  }

  ///找到比目标值大的第一个索引
  ///没找到返回-1
  int findFirstGreaterThanIndex(E target, CompareFun<E> compare) {
    return findFirstGreaterThanIndex2(target, (a, b) => compare(a, b));
  }

  int findFirstGreaterThanIndex2<T>(T target, int Function(E a, T b) compare) {
    int left = 0;
    int right = length - 1;
    int result = -1;
    while (left <= right) {
      int mid = left + ((right - left) ~/ 2);
      int c = compare(this[mid], target);
      if (c > 0) {
        result = mid;
        right = mid - 1;
      } else {
        left = mid + 1;
      }
    }
    return result;
  }

  ///找到比目标值小的第一个索引
  ///没找到返回-1
  int findFirstLessThanIndex(E target, CompareFun<E> compare) {
    int left = 0;
    int right = length - 1;
    int result = -1;

    while (left <= right) {
      int mid = left + ((right - left) ~/ 2);
      int c = compare(this[mid], target);
      if (c < 0) {
        result = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }
    return result;
  }

  int findUpIndex(E value, CompareFun<E> compare) {
    int low = 0;
    int high = length;
    while (low < high) {
      final int mid = (low + high) ~/ 2;
      if (compare(value, this[mid]) >= 0) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }

  int lowerBoundIndex(E value, CompareFun<E> compare) {
    int low = 0;
    int high = length;
    while (low < high) {
      final int mid = (low + high) ~/ 2;
      if (compare(value, this[mid]) <= 0) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }
    return low;
  }

  List<E> copy() {
    return List.from(this);
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

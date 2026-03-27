import 'dart:collection';
import 'dart:math';

enum ConflictAlg { dropOld, dropNew }

class UniqueList<E> extends ListBase<E> {
  final ConflictAlg alg;
  final List<E> _list = <E>[];
  final Map<E, int> _indexMap = <E, int>{};

  UniqueList([this.alg = ConflictAlg.dropNew]);

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    throw UnsupportedError('UniqueList does not support length=');
  }

  @override
  E operator [](int index) => _list[index];

  @override
  void operator []=(int index, E value) {
    RangeError.checkValidIndex(index, _list, 'index');

    final oldValue = _list[index];
    if (oldValue == value) {
      return;
    }

    final existedIndex = _indexMap[value];
    if (existedIndex == null) {
      _list[index] = value;
      _indexMap.remove(oldValue);
      _indexMap[value] = index;
      return;
    }

    if (alg == ConflictAlg.dropNew) {
      return;
    }

    // dropOld: 目标 value 已存在，需要先移除旧位置，再放到 index
    _list.removeAt(existedIndex);
    _indexMap.remove(value);

    if (existedIndex < index) {
      index--;
    }

    _list[index] = value;
    _indexMap.remove(oldValue);
    _reindex(min(existedIndex, index));
  }

  @override
  void add(E element) {
    final index = _indexMap[element];
    if (index != null) {
      if (alg == ConflictAlg.dropNew) {
        return;
      }
      if (index == _list.length - 1) {
        return;
      }
      _list.removeAt(index);
      _list.add(element);
      _reindex(index);
      return;
    }

    _indexMap[element] = _list.length;
    _list.add(element);
  }

  @override
  void addAll(Iterable<E> iterable) {
    for (final e in iterable) {
      add(e);
    }
  }

  @override
  void insert(int index, E element) {
    RangeError.checkValueInInterval(index, 0, _list.length, 'index');

    final existedIndex = _indexMap[element];
    if (existedIndex == null) {
      _list.insert(index, element);
      _reindex(index);
      return;
    }

    if (alg == ConflictAlg.dropNew) {
      return;
    }

    if (existedIndex == index) {
      return;
    }

    _list.removeAt(existedIndex);
    if (existedIndex < index) {
      index--;
    }
    _list.insert(index, element);
    _reindex(min(existedIndex, index));
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    RangeError.checkValueInInterval(index, 0, _list.length, 'index');

    var current = index;
    for (final e in iterable) {
      final oldLen = _list.length;
      insert(current, e);
      if (_list.length > oldLen) {
        current++;
      } else if (alg == ConflictAlg.dropOld && _indexMap[e] == current) {
        current++;
      }
    }
  }

  @override
  bool remove(Object? element) {
    final index = _indexMap[element];
    if (index == null) {
      return false;
    }
    _list.removeAt(index);
    _indexMap.remove(element);
    _reindex(index);
    return true;
  }

  @override
  E removeAt(int index) {
    RangeError.checkValidIndex(index, _list, 'index');
    final removed = _list.removeAt(index);
    _indexMap.remove(removed);
    _reindex(index);
    return removed;
  }

  @override
  E removeLast() {
    if (_list.isEmpty) {
      throw RangeError.index(-1, _list, 'index');
    }
    final removed = _list.removeLast();
    _indexMap.remove(removed);
    return removed;
  }

  @override
  void removeRange(int start, int end) {
    RangeError.checkValidRange(start, end, _list.length);
    if (start == end) {
      return;
    }
    for (var i = start; i < end; i++) {
      _indexMap.remove(_list[i]);
    }
    _list.removeRange(start, end);
    _reindex(start);
  }

  @override
  void clear() {
    _list.clear();
    _indexMap.clear();
  }

  @override
  bool contains(Object? element) => _indexMap.containsKey(element);

  @override
  int indexOf(Object? element, [int start = 0]) {
    final index = _indexMap[element];
    if (index == null || index < start) {
      return -1;
    }
    return index;
  }

  @override
  int lastIndexOf(Object? element, [int? start]) {
    final index = _indexMap[element];
    if (index == null) {
      return -1;
    }
    if (start != null && index > start) {
      return -1;
    }
    return index;
  }

  @override
  void removeWhere(bool Function(E element) test) {
    var write = 0;
    for (var read = 0; read < _list.length; read++) {
      final e = _list[read];
      if (test(e)) {
        _indexMap.remove(e);
        continue;
      }
      if (write != read) {
        _list[write] = e;
      }
      write++;
    }
    if (write != _list.length) {
      _list.removeRange(write, _list.length);
      _reindexFromScratch();
    }
  }

  @override
  void retainWhere(bool Function(E element) test) {
    removeWhere((e) => !test(e));
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    _list.sort(compare);
    _reindexFromScratch();
  }

  @override
  void shuffle([Random? random]) {
    _list.shuffle(random);
    _reindexFromScratch();
  }

  void _reindex(int start) {
    for (var i = start; i < _list.length; i++) {
      _indexMap[_list[i]] = i;
    }
  }

  void _reindexFromScratch() {
    _indexMap.clear();
    for (var i = 0; i < _list.length; i++) {
      _indexMap[_list[i]] = i;
    }
  }

  @override
  String toString() => _list.toString();
}

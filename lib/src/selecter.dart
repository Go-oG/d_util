import 'dart:math' as math;

///一种快速的选择算法，来源于快速排序
///重要:该方法会改变List中元素索引和位置
///移植自 https://github.com/mourner/quickselect
///重新排列项目，使List中的所有在[left, k]的数据都是最小的。第K个元素的索引为[left, right]中的 (k - left + 1)

/// array ：要部分排序的数组（就地）
/// k ：用于部分排序的中间索引（如上定义）
/// left ：要排序的范围的左索引（默认 0 ）
/// right ：右索引（默认情况下是数组的最后一个索引）
/// compareFn ：比较函数
/// example
/// var arr = [65, 28, 59, 33, 21, 56, 22, 95, 50, 12, 90, 53, 28, 77, 39];
/// quickselect(arr, 8);
/// arr is [39, 28, 28, 33, 21, 12, 22, 50, 53, 56, 59, 65, 90, 77, 95]
///                                         ^^ middle index
class FastSelect {
  static void fastSelect<T>(List<T> arr, int k, [int left = 0, int? right, int Function(T a, T b)? compare]) {
    if (left < 0) {
      left = 0;
    }
    right ??= arr.length - 1;
    compare ??= _defaultCompare;
    _fastSelectStep(arr, k, left, right, compare);
  }

  static _fastSelectStep<T>(List<T> arr, int k, int left, int right, int Function(T a, T b) compare) {
    while (right > left) {
      if (right - left > 600) {
        int n = right - left + 1;
        int m = k - left + 1;
        double z = math.log(n);
        double s = 0.5 * math.exp(2 * z / 3);
        double sd = 0.5 * math.sqrt(z * s * (n - s) / n) * (m - n / 2 < 0 ? -1 : 1);
        int newLeft = math.max(left, (k - m * s / n + sd).floor());
        int newRight = math.min(right, (k + (n - m) * s / n + sd).floor());
        _fastSelectStep(arr, k, newLeft, newRight, compare);
      }

      var t = arr[k];
      var i = left;
      var j = right;

      _swap(arr, left, k);
      if (compare(arr[right], t) > 0) _swap(arr, left, right);

      while (i < j) {
        _swap(arr, i, j);
        i++;
        j--;
        while (compare(arr[i], t) < 0) {
          i++;
        }
        while (compare(arr[j], t) > 0) {
          j--;
        }
      }

      if (compare(arr[left], t) == 0) {
        _swap(arr, left, j);
      } else {
        j++;
        _swap(arr, j, right);
      }
      if (j <= k) left = j + 1;
      if (k <= j) right = j - 1;
    }
  }

  static void _swap<T>(List<T> arr, int i, int j) {
    var tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
  }

  static int _defaultCompare<T>(T a, T b) {
    if (a is Comparable) {
      return a.compareTo(b);
    }
    if (a is num) {
      var t = b as num;
      return a < b
          ? -1
          : a > b
              ? 1
              : 0;
    }

    var a1 = a.hashCode;
    var b2 = b.hashCode;
    return a1 < b2
        ? -1
        : a1 > b2
            ? 1
            : 0;
  }
}

class QuickFind {
  static final _kRandom = math.Random();

  static int quickFind<T>(T value, List<T> array, Comparator<T> compare) {
    List<T?> unsorted = array;
    List<T?> temp = List.filled(unsorted.length, null);

    int tempLength = unsorted.length;
    int length = tempLength;
    T pivot = unsorted[0] as T;
    while (length > 0) {
      length = tempLength;
      pivot = unsorted[_kRandom.nextInt(length)]!;
      tempLength = 0;
      for (int i = 0; i < length; i++) {
        T iValue = unsorted[i] as T;
        if (value == iValue) {
          return i;
        }
        final c = compare(value, pivot);
        final c2 = compare(iValue, pivot);
        if (c > 0 && c2 > 0) {
          temp[tempLength++] = iValue;
        } else if (c < 0 && c2 < 0) {
          temp[tempLength++] = iValue;
        }
      }
      unsorted = temp;
      length = tempLength;
    }

    return -1;
  }
}

///在未排序列表中查找第 k 小的元素（0-based）
class IntroSelect {
  static T introSelect<T>(List<T> list, int k, {Comparator<T>? compare}) {
    if (list.isEmpty || k < 0 || k >= list.length) {
      throw ArgumentError('Invalid input or k out of range');
    }

    final comparator = compare ?? (a, b) => (a as Comparable).compareTo(b);

    final int maxDepth = (2 * (math.log(list.length) ~/ math.ln2)).toInt();
    return _introSelect(list, 0, list.length - 1, k, maxDepth, comparator);
  }

  static T _introSelect<T>(
    List<T> list,
    int left,
    int right,
    int k,
    int depthLimit,
    Comparator<T> compare,
  ) {
    while (left < right) {
      if (depthLimit == 0) {
        _heapSelect(list, left, right, k, compare);
        return list[k];
      }

      depthLimit--;

      final pivotIndex = _medianOfThree(list, left, right, compare);
      final newPivotIndex = _partition(list, left, right, pivotIndex, compare);

      if (k == newPivotIndex) {
        return list[k];
      } else if (k < newPivotIndex) {
        right = newPivotIndex - 1;
      } else {
        left = newPivotIndex + 1;
      }
    }

    return list[left];
  }

  static int _partition<T>(
    List<T> list,
    int left,
    int right,
    int pivotIndex,
    Comparator<T> compare,
  ) {
    final pivotValue = list[pivotIndex];
    _swap(list, pivotIndex, right);
    int storeIndex = left;

    for (int i = left; i < right; i++) {
      if (compare(list[i], pivotValue) < 0) {
        _swap(list, storeIndex, i);
        storeIndex++;
      }
    }

    _swap(list, storeIndex, right);
    return storeIndex;
  }

  static int _medianOfThree<T>(
    List<T> list,
    int left,
    int right,
    Comparator<T> compare,
  ) {
    final mid = left + ((right - left) >> 1);
    final a = list[left];
    final b = list[mid];
    final c = list[right];

    if (compare(a, b) < 0) {
      if (compare(b, c) < 0) {
        return mid;
      } else if (compare(a, c) < 0) {
        return right;
      } else {
        return left;
      }
    } else {
      if (compare(a, c) < 0) {
        return left;
      } else if (compare(b, c) < 0) {
        return right;
      } else {
        return mid;
      }
    }
  }

  static void _swap<T>(List<T> list, int i, int j) {
    if (i != j) {
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }

  static void _heapSelect<T>(
    List<T> list,
    int left,
    int right,
    int k,
    Comparator<T> compare,
  ) {
    list.setRange(left, right + 1, list.sublist(left, right + 1)..sort(compare));
  }
}

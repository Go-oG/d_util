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
    if (left < 0) left = 0;
    right ??= arr.length - 1;
    if (right >= arr.length) right = arr.length - 1;
    if (k < left || k > right) return;
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
    if (a is num) {
      b as num;
      return a < b
          ? -1
          : a > b
              ? 1
              : 0;
    }
    if (a is Comparable) {
      return a.compareTo(b);
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

/// 在未排序列表中选择第 k 小的元素（0-based）
///
/// - 会原地修改 [list] 的元素顺序
/// - 平均时间复杂度 O(n)
/// - 最坏情况下通过回退排序避免持续劣化
///
/// 约束：
/// - [k] 必须在 `[0, list.length)` 范围内
/// - 如果未传 [compare]，则元素类型 [T] 必须可比较，即实现了 [Comparable]
///
/// 示例：
/// ```dart
/// final list = [7, 2, 9, 1, 5];
/// final v = IntroSelect.select(list, 2);
/// // v == 5
/// // 此时 list 已被部分重排，但不保证整体有序
/// ```
class IntroSelect {
  /// 返回列表中第 k 小的元素（0-based）
  /// - `k = 0` 表示最小值
  /// - `k = list.length - 1` 表示最大值
  static T select<T>(
    List<T> list,
    int k, {
    Comparator<T>? compare,
  }) {
    if (list.isEmpty) {
      throw ArgumentError.value(list, 'list', 'list must not be empty');
    }
    if (k < 0 || k >= list.length) {
      throw RangeError.range(k, 0, list.length - 1, 'k');
    }

    final cmp = compare ?? _defaultComparator<T>;
    if (list.length == 1) {
      return list[0];
    }

    final depthLimit = _maxDepth(list.length);
    return _selectRange(list, 0, list.length - 1, k, depthLimit, cmp);
  }

  static T _selectRange<T>(
    List<T> list,
    int left,
    int right,
    int k,
    int depthLimit,
    Comparator<T> compare,
  ) {
    var l = left;
    var r = right;
    var depth = depthLimit;

    while (l < r) {
      // 小区间直接排序，减少递归/分区常数
      if (r - l <= 24) {
        _sortRange(list, l, r, compare);
        return list[k];
      }

      // 深度耗尽时回退到区间排序，保证实现稳健
      if (depth == 0) {
        _sortRange(list, l, r, compare);
        return list[k];
      }
      depth--;

      final pivotIndex = _medianOfThree(list, l, r, compare);
      final newPivotIndex = _partition(list, l, r, pivotIndex, compare);

      if (k == newPivotIndex) {
        return list[k];
      } else if (k < newPivotIndex) {
        r = newPivotIndex - 1;
      } else {
        l = newPivotIndex + 1;
      }
    }

    return list[l];
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

    var storeIndex = left;
    for (var i = left; i < right; i++) {
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

    if (compare(list[left], list[mid]) > 0) {
      _swap(list, left, mid);
    }
    if (compare(list[left], list[right]) > 0) {
      _swap(list, left, right);
    }
    if (compare(list[mid], list[right]) > 0) {
      _swap(list, mid, right);
    }

    return mid;
  }

  static void _sortRange<T>(
    List<T> list,
    int left,
    int right,
    Comparator<T> compare,
  ) {
    final sorted = list.sublist(left, right + 1)..sort(compare);
    list.setRange(left, right + 1, sorted);
  }

  static void _swap<T>(List<T> list, int i, int j) {
    if (i == j) {
      return;
    }
    final tmp = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }

  static int _maxDepth(int length) {
    // 2 * floor(log2(n))
    return math.max(1, 2 * (math.log(length) / math.ln2).floor());
  }

  static int _defaultComparator<T>(T a, T b) {
    final aa = a;
    if (aa is Comparable<T>) {
      return aa.compareTo(b);
    }
    if (aa is Comparable) {
      return aa.compareTo(b);
    }
    throw ArgumentError(
      'No comparator provided for type $T. '
      'Pass compare explicitly or make the type implement Comparable.',
    );
  }
}

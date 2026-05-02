
import '../extensions/num_ext.dart';

final class CompareUtil {
  CompareUtil._();

  static int compareObj(Object? a, Object? b, {bool reverse = false}) {
    final c = _compareObj(a, b);
    if (reverse) {
      return -c;
    }
    return c;
  }

  static int _compareObj(Object? a, Object? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is Comparable && b is Comparable) {
      try {
        return a.compareTo(b);
      } catch (_) {}
    }

    final an = asNum(a, allowDateTime: true);
    final bn = asNum(b, allowDateTime: true);
    if (an != null && bn != null) {
      return an.compareTo(bn);
    }
    return a.toString().compareTo(b.toString());
  }
}
import 'dart:collection';

extension TreeSetExt<E extends Comparable<Object>> on SplayTreeSet<E> {
  E? higher(E element) {
    for (final e in this) {
      if (e.compareTo(element) > 0) {
        return e;
      }
    }
    return null;
  }

  E? ceiling(E element) {
    for (final e in this) {
      if (e.compareTo(element) >= 0) {
        return e;
      }
    }
    return null;
  }

  E? lower(E element) {
    E? result;
    for (final e in this) {
      if (e.compareTo(element) >= 0) {
        break;
      }
      result = e;
    }
    return result;
  }

  E? floor(E element) {
    E? result;
    for (final e in this) {
      if (e.compareTo(element) > 0) {
        break;
      }
      result = e;
    }
    return result;
  }
}

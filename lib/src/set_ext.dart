import 'dart:collection';

import 'package:collection/collection.dart';

extension TreeSetExt<E extends Comparable> on SplayTreeSet<E> {
  E? higher(E element) {
    return firstWhereOrNull((e) => e.compareTo(element) > 0);
  }

  E? lower(E element) {
    var lowerElements = where((e) => e.compareTo(element) < 0);
    return lowerElements.isEmpty ? null : lowerElements.last;
  }
}

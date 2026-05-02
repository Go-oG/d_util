import 'package:flutter/foundation.dart';

abstract interface class Disposable {
  void dispose();
}

abstract class AbstractDisposable implements Disposable {
  @override
  void dispose() {}
}

void disposeObj(dynamic obj) {
  try {
    obj.dispose();
  } catch (e) {
    debugPrint(e.toString());
  }
}

void disposeList(Iterable<Disposable?> labelList) {
  for (var e in labelList) {
    e?.dispose();
  }
}

mixin DisposerMixin on Disposable {
  List<Disposable> _disposeList = [];

  bool _disposed = false;

  void addDispose(Disposable dispose) {
    _disposeList.add(dispose);
  }

  bool get isDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    final old = _disposeList;
    _disposeList = [];
    disposeList(old);
    super.dispose();
  }
}

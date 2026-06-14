import 'package:flutter/foundation.dart';

import '../model/priority.dart';
import '../types.dart';
import 'disposable.dart';

abstract interface class IValueObs<T> implements Disposable {
  T get value;

  set value(T v);

  void addListener(VoidFun1<T>? listener);

  void removeListener(VoidFun1<T>? listener);

  void clearListener();

  void notifyListeners();

  bool hasListener(VoidFun1<T> listener);

  bool get hasListeners;

  List<VoidFun1<T>> get listeners;
}

class ValueObs<T> implements IValueObs<T> {
  static const int _kInitialCapacity = 4;

  ///表示通知时是否从低优先级到高优先级通知
  ///默认从低到高进行通知
  final bool lowToHigh;
  final bool equalsObject;
  List<_ListenerEntry<T>?> _listeners = const [];
  int _count = 0;
  int _notifyDepth = 0;
  int _removedInNotify = 0;
  T _value;

  ValueObs(this._value, {this.equalsObject = false, this.lowToHigh = true});

  @override
  T get value => _value;

  @override
  set value(T v) {
    if (equalsObject) {
      if (v == _value) return;
    } else {
      if (identical(v, _value)) return;
    }
    _value = v;
    notifyListeners();
  }

  @override
  bool get hasListeners => _count > 0;

  @override
  void addListener(VoidFun1<T>? listener) => addListener2(listener);

  void addListener2(
    VoidFun1<T>? listener, [
    Priority priority = Priority.normal,
  ]) {
    if (listener == null) return;
    if (_count == _listeners.length) {
      final newCap = (_count == 0) ? _kInitialCapacity : _listeners.length * 2;
      final newList = List<_ListenerEntry<T>?>.filled(newCap, null);
      for (int i = 0; i < _count; i++) {
        newList[i] = _listeners[i];
      }
      _listeners = newList;
    }
    final entry = _ListenerEntry<T>(listener, priority);

    int insertIndex = _count;
    for (int i = 0; i < _count; i++) {
      final current = _listeners[i];
      if (current == null) continue;
      int c = priority.compareTo(current.priority);
      if (!lowToHigh) {
        c = -c;
      }
      if (c < 0) {
        insertIndex = i;
        break;
      }
    }

    if (insertIndex < _count) {
      for (int i = _count; i > insertIndex; i--) {
        _listeners[i] = _listeners[i - 1];
      }
    }
    _listeners[insertIndex] = entry;
    _count++;
  }

  @override
  void removeListener(VoidFun1<T>? listener) {
    if (listener == null || _count == 0) return;
    for (int i = 0; i < _count; i++) {
      final entry = _listeners[i];
      if (entry != null && identical(entry.callback, listener)) {
        _listeners[i] = null;
        if (_notifyDepth > 0) {
          _removedInNotify++;
        }
      }
    }
    if (_notifyDepth == 0) {
      _compactIfNeeded();
    }
  }

  @mustCallSuper
  @override
  void clearListener() {
    _listeners = const [];
    _count = 0;
    _notifyDepth = 0;
    _removedInNotify = 0;
  }

  @mustCallSuper
  @override
  void notifyListeners() {
    if (_count == 0) return;
    _notifyDepth++;
    try {
      final tmpValue = _value;
      final end = _count;

      for (int i = 0; i < end; i++) {
        final entry = _listeners[i];
        if (entry != null) {
          entry.callback(tmpValue);
        }
      }
    } finally {
      _notifyDepth--;
      if (_notifyDepth == 0 && _removedInNotify > 0) {
        _compactIfNeeded();
        _removedInNotify = 0;
      }
    }
  }

  @mustCallSuper
  @override
  bool hasListener(VoidFun1<T> listener) {
    for (int i = 0; i < _count; i++) {
      final entry = _listeners[i];
      if (entry != null && identical(entry.callback, listener)) {
        return true;
      }
    }
    return false;
  }

  @override
  List<VoidFun1<T>> get listeners {
    if (_count == 0) return const [];

    final out = <VoidFun1<T>>[];
    for (int i = 0; i < _count; i++) {
      final entry = _listeners[i];
      if (entry != null) {
        out.add(entry.callback);
      }
    }
    return out;
  }

  List<({VoidFun1<T> listener, int priority})> get listenersWithPriority {
    if (_count == 0) return const [];

    final out = <({VoidFun1<T> listener, int priority})>[];
    for (int i = 0; i < _count; i++) {
      final entry = _listeners[i];
      if (entry != null) {
        out.add((listener: entry.callback, priority: entry.priority));
      }
    }
    return out;
  }

  void _compactIfNeeded() {
    if (_count == 0) {
      _listeners = const [];
      return;
    }

    int write = 0;
    for (int read = 0; read < _count; read++) {
      final entry = _listeners[read];
      if (entry != null) {
        _listeners[write++] = entry;
      }
    }

    for (int i = write; i < _count; i++) {
      _listeners[i] = null;
    }

    _count = write;

    final cap = _listeners.length;
    if (cap >= _kInitialCapacity && _count * 3 <= cap) {
      final newCap = (_count == 0)
          ? 0
          : (_count * 2).clamp(_kInitialCapacity, 1 << 30);

      final newList = newCap == 0
          ? <_ListenerEntry<T>>[]
          : List<_ListenerEntry<T>?>.filled(newCap, null);

      for (int i = 0; i < _count; i++) {
        newList[i] = _listeners[i];
      }
      _listeners = newList;
    }
  }

  @mustCallSuper
  @override
  void dispose() {
    clearListener();
  }
}

mixin ValuesObsProxyMixin<T> implements IValueObs<T> {
  ValueObs<T> get valueObs;

  @override
  void addListener(VoidFun1<T>? listener) => valueObs.addListener(listener);

  @override
  void clearListener() => valueObs.clearListener();

  @override
  void dispose() => valueObs.dispose();

  @override
  bool hasListener(VoidFun1<T> listener) => valueObs.hasListener(listener);

  @override
  void notifyListeners() => valueObs.notifyListeners();

  @override
  void removeListener(VoidFun1<T>? listener) =>
      valueObs.removeListener(listener);

  @override
  List<VoidFun1<T>> get listeners => valueObs.listeners;

  @override
  bool get hasListeners => valueObs.hasListeners;

  @override
  set value(T v) => valueObs.value = v;

  @override
  T get value => valueObs.value;
}

class _ListenerEntry<T> {
  final VoidFun1<T> callback;

  final Priority priority;

  const _ListenerEntry(this.callback, this.priority);
}

class BroadcastObs<T> implements Disposable {
  late final ValueObs<_NeverEqual<T>> _notifier;
  final Map<VoidFun1<T>, ListenerSubscription<T>> _map = {};

  BroadcastObs({bool lowToHigh = true}) {
    _notifier = ValueObs(_NeverEqual._default(), lowToHigh: lowToHigh);
  }

  ListenerSubscription<T> listen(
    VoidFun1<T> listener, [
    Priority priority = Priority.normal,
  ]) {
    _map[listener]?.dispose();
    var result = ListenerSubscription<T>._(listener, this);
    _map[listener] = result;
    _notifier.addListener2(result._onCall, priority);
    return result;
  }

  void _removeSubscription(ListenerSubscription<T> subscription) {
    final listener = subscription._listener;
    if (listener != null && identical(_map[listener], subscription)) {
      _map.remove(listener);
    }
    _notifier.removeListener(subscription._onCall);
  }

  void notify(T tmpValue) {
    _notifier.value = _NeverEqual(tmpValue);
  }

  T? get value {
    var data = _notifier.value;
    if (data.defaultData) {
      return null;
    }
    return data.data;
  }

  @override
  void dispose() {
    final old = _map.values.toList(growable: false);
    for (var e in old) {
      e.dispose();
    }
    _map.clear();
    _notifier.dispose();
  }

  bool get hasListener => _map.isNotEmpty;
}

final class ListenerSubscription<T> implements Disposable {
  VoidFun1<T>? _listener;
  BroadcastObs<T>? _notifier;

  ListenerSubscription._(this._listener, this._notifier);

  void _onCall(_NeverEqual<T> value) {
    var data = value.data;
    if (data != null && !value.defaultData) {
      _listener?.call(data);
    }
  }

  @override
  void dispose() {
    _notifier?._removeSubscription(this);
    _listener = null;
    _notifier = null;
  }

  void notify(T? value) {
    if (value == null) {
      return;
    }
    _listener?.call(value);
  }
}

mixin BroadcastSubMixin on Disposable {
  final Map<Object, ListenerSubscription> _subsMap = {};

  void addSubscription<T>(
    Object key,
    BroadcastObs<T> obs,
    VoidFun1<T> listener, [
    Priority priority = Priority.normal,
  ]) {
    _subsMap.remove(key)?.dispose();
    final result = obs.listen(listener, priority);
    _subsMap[key] = result;
  }

  ListenerSubscription<T>? getSubscription<T>(Object key) =>
      _subsMap[key] as ListenerSubscription<T>?;

  @override
  void dispose() {
    for (var e in _subsMap.values) {
      e.dispose();
    }
    _subsMap.clear();

    super.dispose();
  }
}

final class _NeverEqual<T> {
  final bool defaultData;
  final T? data;

  _NeverEqual(this.data) : defaultData = false;

  _NeverEqual._default() : data = null, defaultData = true;

  @override
  bool operator ==(Object other) {
    return false;
  }

  @override
  int get hashCode => data == null ? super.hashCode : data.hashCode;
}

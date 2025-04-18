import 'types.dart';
import 'list_ext.dart';

extension MapExt<K, V> on Map<K, V> {

  void set(K k, V value) => this[k] = value;

  void put(K k, V value) => this[k] = value;

  V? get(K k) => this[k];

  V get2(K k, [V Function()? builder]) {
    var v = this[k];
    if (v != null) {
      return v;
    }
    if (builder != null) {
      v = builder();
      this[k] = v as V;
      return v;
    }
    throw "Not value";
  }

  V getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }

  int get size => length;

  void each(Function(K key, V value) fun) {
    for (var entry in entries) {
      fun.call(entry.key, entry.value);
    }
  }

  ///按照key排序后的顺序访问
  void eachSort(CompareFun<K> compare, Function(K key, V value) fun) {
    List<K> keyList = List.from(keys);
    keyList.sort(compare);
    for (var k in keyList) {
      fun(k, this[k] as V);
    }
  }

  MapEntry<K, V> min(CompareFun<MapEntry<K, V>> compare) {
    return entries.min(compare);
  }

  MapEntry<K, V> minBy(CompareFun2<MapEntry<K, V>> compare) {
    return entries.maxBy(compare);
  }

  MapEntry<K, V> max(CompareFun<MapEntry<K, V>> compare) {
    return entries.max(compare);
  }

  MapEntry<K, V> maxBy(CompareFun2<MapEntry<K, V>> compare) {
    return entries.maxBy(compare);
  }

  List<MapEntry<K, V>> extreme(CompareFun<MapEntry<K, V>> compare) {
    return entries.extreme(compare);
  }

  double sum(double Function(K key, V value) sumFun, {double initValue = 0}) {
    double sum = initValue;
    for (var item in entries) {
      sum += sumFun(item.key, item.value);
    }
    return sum;
  }




}

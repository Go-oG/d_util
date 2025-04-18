typedef CompareFun<E> = int Function(E a, E b);
typedef CompareFun2<E> = Comparable Function(E a);
typedef EachFun<E> = void Function(E data, int index);
typedef Fun1<A> = void Function(A a);
typedef Fun2<A, B> = B Function(A a);
typedef Fun3<A, B, C> = C Function(A a, B b);
typedef Fun4<A, B, C, D> = D Function(A a, B b, C c);
typedef Fun5<A, B, C, D, E> = E Function(A a, B b, C c, D d);

typedef VoidFun1<A> = void Function(A a);
typedef VoidFun2<A, B> = void Function(A a, B b);
typedef VoidFun3<A, B, C> = void Function(A a, B b, C c);
typedef VoidFun4<A, B, C, D> = void Function(A a, B b, C c, D d);
typedef VoidFun5<A, B, C, D, E> = void Function(A a, B b, C c, D d, E e);

mixin InitMixin {
  var _init = false;

  ///当已经初始化了则返回true
  ///否则返回false并自动进行标记
  bool getAndMarkInit() {
    if (_init) {
      return true;
    }
    _init = true;
    return false;
  }
}

abstract interface class CComparator<T> {
  int compare(T o1, T o2);
}

class CComparator2<T> implements CComparator<T> {
  final Comparator<T> comparator;

  CComparator2(this.comparator);

  @override
  int compare(T o1, T o2) {
    return comparator(o1, o2);
  }
}

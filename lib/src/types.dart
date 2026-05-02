
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



class Stack<E> {
  final List<E> _list = [];

  void push(E e) {
    _list.add(e);
  }

  E pop() {
    return _list.removeLast();
  }

  int get size => _list.length;

  E get(int index) => _list[index];

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  E peek() => _list.last;

  void add(E e) {
    _list.add(e);
  }


}
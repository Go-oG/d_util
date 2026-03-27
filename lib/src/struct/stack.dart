class Stack<E> with Iterable<E> {
  final List<E> _list = [];

  void push(E e) {
    _list.add(e);
  }

  E pop() {
    return _list.removeLast();
  }

  int get size => _list.length;

  E get(int index) => _list[index];

  @override
  E get last => _list[_list.length - 1];

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  E peek() => _list.last;

  void add(E e) {
    _list.add(e);
  }

  @override
  Iterator<E> get iterator => _list.iterator;
}

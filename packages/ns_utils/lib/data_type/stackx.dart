import 'dart:collection';

///[StackX] is Stack like DS
class StackX<T> {
  final ListQueue<T> _list = ListQueue<T>();

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  void push(T element) => _list.addLast(element);

  bool contains(T element) => _list.contains(element);

  T pop() {
    final T element = _list.last;
    _list.removeLast();
    return element;
  }

  T top() => _list.last;

  List<T> addAll(List<T> elements) {
    _list.addAll(elements);
    return _list.toList();
  }
}

import 'package:flutter/material.dart';

class Node {
  final Offset position;
  final double g;
  final double f;

  Node(this.position, this.g, this.f);
}




class PriorityQueue<T> {
  final List<PriorityQueueNode<T>> _elements = [];

  void add(T element, double priority) {
    _elements.add(PriorityQueueNode(element, priority));
    _elements.sort((a, b) => a.priority.compareTo(b.priority));
  }

  T removeFirst() {
    if (_elements.isEmpty) {
      throw StateError('No elements to remove');
    }
    return _elements.removeAt(0).element;
  }

  bool get isEmpty => _elements.isEmpty;

  @override
  String toString() {
    return _elements.toString();
  }
}




class PriorityQueueNode<T> {
  final T element;
  final double priority;

  PriorityQueueNode(this.element, this.priority);

  @override
  String toString() {
    return 'PriorityQueueNode(element: $element, priority: $priority)';
  }
}

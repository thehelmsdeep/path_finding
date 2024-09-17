

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:math';


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











void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PathfinderGrid(),
    );
  }
}



class PathfinderGrid extends StatefulWidget {
  @override
  _PathfinderGridState createState() => _PathfinderGridState();
}

class _PathfinderGridState extends State<PathfinderGrid> {
  static const int gridSize = 50;

  List<List<bool>> grid =
  List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));

  Offset? startPoint;
  Offset? endPoint;
  List<Offset> path = [];
  List<Offset> visitedOrder = [];

  @override
  void initState() {
    super.initState();
    addStaticObstacles();
  }




  Future<List<Offset>> aStar(Offset start, Offset goal) async {
    PriorityQueue<Offset> openSet = PriorityQueue<Offset>();
    Map<Offset, Offset?> cameFrom = {};
    Map<Offset, double> gScore = {};
    Set<Offset> visitedSet = {};

    gScore[start] = 0;
    openSet.add(start, heuristic(start, goal));
    cameFrom[start] = null;

    while (!openSet.isEmpty) {
      Offset current = openSet.removeFirst();
      visitedOrder.add(current);

      setState(() {});
      await Future.delayed(const Duration(milliseconds: 2));

      if (current == goal) {
        return reconstructPath(cameFrom, current);
      }

      for (Offset neighbor in getNeighbors(current)) {
        if (visitedSet.contains(neighbor)) continue;

        double tentativeGScore = gScore[current]! + 1;
        double currentGScore = gScore[neighbor] ?? double.infinity;

        if (tentativeGScore < currentGScore) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeGScore;

          double fScore = tentativeGScore + heuristic(neighbor, goal);
          openSet.add(neighbor, fScore);
        }
      }
      visitedSet.add(current);
    }

    return [];
  }






  // Heuristic function: Manhattan distance
  double heuristic(Offset a, Offset b) {
    return (a.dx - b.dx).abs() + (a.dy - b.dy).abs();
  }

  List<Offset> getNeighbors(Offset point) {
    List<Offset> neighbors = [];
    List<Offset> potentialNeighbors = const [
      Offset(0, 1), // Right
      Offset(1, 0), // Down
      Offset(0, -1), // Left
      Offset(-1, 0), // Up
      Offset(1, 1), // Down-right (diagonal)
      Offset(1, -1), // Down-left (diagonal)
      Offset(-1, 1), // Up-right (diagonal)
      Offset(-1, -1) // Up-left (diagonal)
    ];

    for (Offset offset in potentialNeighbors) {
      Offset neighbor = point + offset;
      if (isInBounds(neighbor) &&
          !grid[neighbor.dx.toInt()][neighbor.dy.toInt()]) {
        neighbors.add(neighbor);
      }
    }

    return neighbors;
  }






  bool isInBounds(Offset point) {
    return point.dx >= 0 &&
        point.dx < gridSize &&
        point.dy >= 0 &&
        point.dy < gridSize;
  }



  List<Offset> reconstructPath(Map<Offset, Offset?> cameFrom, Offset current) {
    List<Offset> path = [current];
    while (cameFrom[current] != null) {
      current = cameFrom[current]!;
      path.add(current);
    }
    return path.reversed.toList();
  }



  void findShortestPath() async {
    if (startPoint == null || endPoint == null) return;

    setState(() {
      path.clear();
      visitedOrder.clear();
    });

    List<Offset> shortestPath =
    await aStar(startPoint!, endPoint!); // Use A* algorithm
    setState(() {
      path = shortestPath; // Display the shortest path after search completes
    });
  }




  void addStaticObstacles() {
    List<Offset> staticObstacles = const [
      Offset(22, 23),
      Offset(22, 24),
      Offset(23, 23),
      Offset(23, 24),
      Offset(24, 23),
      Offset(24, 24),
      Offset(25, 23),
      Offset(25, 24),
      Offset(26, 23),
      Offset(26, 24),
      Offset(27, 23),
      Offset(27, 24),
      Offset(28, 23),
      Offset(28, 24),
      Offset(29, 23),
      Offset(29, 24),
      Offset(20, 20),
      Offset(20, 21),
      Offset(21, 20),
      Offset(21, 21),
      Offset(22, 20),
      Offset(22, 21),
      Offset(23, 20),
      Offset(23, 21),
      Offset(24, 20),
      Offset(24, 21),
      Offset(25, 20),
      Offset(25, 21),
      Offset(26, 20),
      Offset(26, 21),
      Offset(28, 20),
      Offset(28, 21),
      Offset(29, 20),
      Offset(29, 21),
      Offset(30, 20),
      Offset(30, 21),
      Offset(31, 20),
      Offset(31, 21),
      Offset(32, 20),
      Offset(32, 21),
      Offset(33, 20),
      Offset(33, 21),
      Offset(34, 20),
      Offset(34, 21),
      Offset(35, 20),
      Offset(35, 21),
      Offset(36, 20),
      Offset(36, 21),
    ];

    for (Offset obstacle in staticObstacles) {
      setState(() {
        grid[obstacle.dx.toInt()][obstacle.dy.toInt()] = true;
      });
    }
  }




  void reset() {
    path.clear();
    startPoint = null;
    endPoint = null;
    visitedOrder.clear();
    grid =
        List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));
    addStaticObstacles();
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        title: const Text('A* Pathfinding'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    int row = index ~/ gridSize;
                    int col = index % gridSize;
                    Offset point = Offset(row.toDouble(), col.toDouble());

                    Color color;

                    if (startPoint == point) {
                      color = Colors.blue;
                    } else if (endPoint == point) {
                      color = Colors.red;
                    } else if (grid[row][col]) {
                      color = Colors.grey.shade400;
                    } else if (path.contains(point)) {
                      color = Colors.blue.shade300;
                    } else if (visitedOrder.contains(point)) {
                      color = Colors.orange.shade100;
                    } else {
                      color = Colors.white;
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (startPoint == null) {
                            startPoint = point;
                          } else if (endPoint == null) {
                            endPoint = point;
                          } else {
                            grid[row][col] = !grid[row][col];
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 100,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                onPressed: findShortestPath,
                color: Colors.blue,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: const Text("Find"),
              ),
              MaterialButton(
                onPressed: reset,
                color: Colors.white,
                textColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: const Text("Reset"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Node {
  final Offset position;
  final double g;
  final double f;

  Node(this.position, this.g, this.f);
}






import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:collection';

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

  // grid: false = empty, true = obstacle
  List<List<bool>> grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));

  Offset? startPoint;
  Offset? endPoint;
  List<Offset> path = [];
  List<Offset> visitedOrder = [];

  @override
  void initState() {
    super.initState();
    addStaticObstacles();
  }



  // Breadth-First Search (BFS) Algorithm with delay for visualization
  Future<List<Offset>> bfs(Offset start, Offset goal) async {
    Queue<Offset> queue = Queue();
    Map<Offset, Offset?> cameFrom = {};
    Set<Offset> visitedSet = {};

    queue.add(start);
    visitedSet.add(start);
    cameFrom[start] = null;

    while (queue.isNotEmpty) {
      Offset current = queue.removeFirst();
      visitedOrder.add(current); // Record the visit order

      setState(() {}); // Update the UI to show the visited cell
      await Future.delayed(const Duration(milliseconds: 20)); // Add a delay to visualize search

      if (current == goal) {
        return reconstructPath(cameFrom, current); // Return the shortest path
      }

      for (Offset neighbor in getNeighbors(current)) {
        if (!visitedSet.contains(neighbor)) {
          queue.add(neighbor);
          visitedSet.add(neighbor);
          cameFrom[neighbor] = current;
        }
      }
    }

    return [];
  }






  List<Offset> getNeighbors(Offset point) {
    List<Offset> neighbors = [];
    List<Offset> potentialNeighbors = const [
      Offset(0, 1),  // Right
      Offset(1, 0),  // Down
      Offset(0, -1), // Left
      Offset(-1, 0), // Up
      Offset(1, 1),  // Down-right (diagonal)
      Offset(1, -1), // Down-left (diagonal)
      Offset(-1, 1), // Up-right (diagonal)
      Offset(-1, -1) // Up-left (diagonal)
    ];

    for (Offset offset in potentialNeighbors) {
      Offset neighbor = point + offset;
      if (isInBounds(neighbor) && !grid[neighbor.dx.toInt()][neighbor.dy.toInt()]) {
        neighbors.add(neighbor);
      }
    }

    return neighbors;
  }





  bool isInBounds(Offset point) {
    return point.dx >= 0 && point.dx < gridSize && point.dy >= 0 && point.dy < gridSize;
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

    List<Offset> shortestPath = await bfs(startPoint!, endPoint!); // Wait for the BFS to complete
    setState(() {
      path = shortestPath; // Display the shortest path after search completes
    });
  }







  void addStaticObstacles() {
    List<Offset> staticObstacles = const [
      Offset(20, 20), Offset(20, 21),
      Offset(21, 20), Offset(21, 21),
      Offset(22, 20), Offset(22, 21),
      Offset(23, 20), Offset(23, 21),
      Offset(24, 20), Offset(24, 21),
      Offset(25, 20), Offset(25, 21),
      Offset(26, 20), Offset(26, 21),
      Offset(28, 20), Offset(28, 21),
      Offset(29, 20), Offset(29, 21),
      Offset(30, 20), Offset(30, 21),
      Offset(31, 20), Offset(31, 21),
      Offset(32, 20), Offset(32, 21),
      Offset(33, 20), Offset(33, 21),
      Offset(34, 20), Offset(34, 21),
      Offset(35, 20), Offset(35, 21),
      Offset(36, 20), Offset(36, 21),
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
    grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));
    addStaticObstacles();
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        title: const Text('BFS Pathfinding'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: findShortestPath,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: reset,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,

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
    );
  }



}

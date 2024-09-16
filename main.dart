import 'package:flutter/material.dart';
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

class _PathfinderGridState extends State<PathfinderGrid> with SingleTickerProviderStateMixin {
  static const int gridSize = 80;

  // grid: false = empty, true = obstacle
  List<List<bool>> grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));


  Offset? startPoint;
  Offset? endPoint;
  List<Offset> path = [];
  List<Offset> animatedPath = [];

  AnimationController? _animationController;
  Animation<int>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
    );
    addStaticObstacles();
  }



  // Breadth-First Search (BFS) Algorithm
  List<Offset> bfs(Offset start, Offset goal) {
    Queue<Offset> queue = Queue();
    Map<Offset, Offset?> cameFrom = {};
    Set<Offset> visited = {};

    queue.add(start);
    visited.add(start);
    cameFrom[start] = null;

    while (queue.isNotEmpty) {
      Offset current = queue.removeFirst();

      if (current == goal) {
        return reconstructPath(cameFrom, current);
      }

      for (Offset neighbor in getNeighbors(current)) {
        if (!visited.contains(neighbor)) {
          queue.add(neighbor);
          visited.add(neighbor);
          cameFrom[neighbor] = current;
        }
      }
    }

    return []; // Return empty list if no path is found
  }




  // Distance between two points
  double distanceBetween(Offset a, Offset b) {
    double dx = (a.dx - b.dx).abs();
    double dy = (a.dy - b.dy).abs();
    if (dx == 1 && dy == 1) {
      return 1.414; // Diagonal movement
    }
    return 1.0; // Horizontal or vertical movement
  }





  // Get valid neighbors of the current point
  List<Offset> getNeighbors(Offset point) {
    List<Offset> neighbors = [];
    List<Offset> potentialNeighbors = const[
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





  // Check if the point is within bounds of the grid
  bool isInBounds(Offset point) {
    return point.dx >= 0 && point.dx < gridSize && point.dy >= 0 && point.dy < gridSize;
  }



  // Reconstruct the path from the cameFrom map
  List<Offset> reconstructPath(Map<Offset, Offset?> cameFrom, Offset current) {
    List<Offset> path = [current];
    while (cameFrom[current] != null) {
      current = cameFrom[current]!;
      path.add(current);
    }
    return path.reversed.toList();
  }




  // Helper function to find shortest path using BFS algorithm
  void findShortestPath() {
    if (startPoint == null || endPoint == null) return;

    setState(() {
      path.clear();
    });

    List<Offset> shortestPath = bfs(startPoint!, endPoint!);
    setState(() {
      path = shortestPath;
      animatedPath = []; // Reset animation path
    });

    // Animate the path drawing
    if (path.isNotEmpty) {
      int durationPerStep = 150; // Duration for each step (milliseconds)
      _animationController!.duration = Duration(milliseconds: durationPerStep * path.length);

      _animation = IntTween(begin: 0, end: path.length).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
      ));

      _animationController!.forward(from: 0.0);

      // Update animatedPath with animation
      _animation!.addListener(() {
        final int value = _animation!.value;
        setState(() {
          animatedPath = path.sublist(0, value);
        });
      });
    }
  }






  //  obstacles
  void addStaticObstacles() {

    List<Offset> staticObstacles = const [
      Offset(20, 20),Offset(20, 21),
      Offset(21, 20),Offset(21, 21),
      Offset(22, 20),Offset(22, 21),
      Offset(23, 20),Offset(23, 21),
      Offset(24, 20),Offset(24, 21),
      Offset(25, 20),Offset(25, 21),
      Offset(26, 20),Offset(26, 21),
      Offset(28, 20),Offset(28, 21),
      Offset(29, 20),Offset(29, 21),
      Offset(30, 20),Offset(30, 21),
      Offset(31, 20),Offset(31, 21),
      Offset(32, 20),Offset(32, 21),
      Offset(33, 20),Offset(33, 21),
      Offset(34, 20),Offset(34, 21),
      Offset(35, 20),Offset(35, 21),
      Offset(36, 20),Offset(36, 21),
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
    animatedPath.clear();
    _animationController?.stop();
    grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => false)); // Reset grid
    addStaticObstacles(); // Add static obstacles back after reset
    setState(() {});
  }





  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
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
              color = Colors.blue; // Start point
            } else if (endPoint == point) {
              color = Colors.red; // End point
            } else if (grid[row][col]) {
              color = Colors.grey.shade400; // Static obstacle
            } else if (animatedPath.contains(point)) {
              color = Colors.blue.shade300;
            } else if (path.contains(point)) {
              color = Colors.white; // Path not yet animated
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

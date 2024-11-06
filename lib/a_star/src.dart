import 'dart:math';

import 'package:bfs_path_finding/a_star/heuristic_methods.dart';
import 'package:bfs_path_finding/a_star/model.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AStarPathfinder extends StatefulWidget {
  @override
  _AStarPathfinderState createState() => _AStarPathfinderState();
}

class _AStarPathfinderState extends State<AStarPathfinder> {
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
  }

  Future<List<Offset>> aStar(
      Offset start, Offset goal, HeuristicType hType) async {
    PriorityQueue<Offset> openSet = PriorityQueue<Offset>();
    Map<Offset, Offset?> cameFrom = {};
    Map<Offset, double> gScore = {};
    Set<Offset> visitedSet = {};

    gScore[start] = 0;
    openSet.add(start, hType.calculateDistance(start, goal));
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

          double fScore =
              tentativeGScore + hType.calculateDistance(neighbor, goal);
          openSet.add(neighbor, fScore);
        }
      }
      visitedSet.add(current);
    }

    return [];
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

  void findShortestPath(HeuristicType hType) async {
    if (startPoint == null || endPoint == null) return;

    setState(() {
      path.clear();
      visitedOrder.clear();
    });

    List<Offset> shortestPath = await aStar(startPoint!, endPoint!, hType);
    setState(() {
      path = shortestPath; // Display the shortest path after search completes
    });
  }

  void addDynamicObstacles() {

    Random random = Random();
    for (int i = 0; i < 30; i++) {
      int x = random.nextInt(gridSize);
      int y = random.nextInt(gridSize);
      setState(() {
        grid[x][y] = true; // mark as obstacle
      });
    }
  }

// A function to handle tap events dynamically, such as toggling obstacles
  void toggleObstacleAt(Offset point) {
    int row = point.dx.toInt();
    int col = point.dy.toInt();

    setState(() {
      grid[row][col] = !grid[row][col]; // Toggle the obstacle
    });
  }

  void reset() {
    path.clear();
    startPoint = null;
    endPoint = null;
    visitedOrder.clear();
    grid =
        List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));

    setState(() {});
  }


  int? selectedButtonIndex;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,

      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'MyCustomFont',
                  color: Colors.grey.shade400,
                  fontSize: 17,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'A-star',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const TextSpan(
                    text: ' search algorithm',
                  ),
                ],
              ),
            )
            ,

            const SizedBox(height: 24,),

            SizedBox(
              width: double.infinity,
              height: 300,
              child: Card(
                elevation: 5,
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
                        color = Colors.orange;
                      } else if (endPoint == point) {
                        color = Colors.purple;
                      } else if (grid[row][col]) {
                        color = Colors.grey.shade400;
                      } else if (path.contains(point)) {
                        color = Colors.red;
                      } else if (visitedOrder.contains(point)) {
                        color = Colors.blue.shade200;
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
            const SizedBox(
              height: 50,
            ),

            buttons

          ],
        ),
      ),
    );
  }


  Widget get buttons => Column(
    children: [
      MaterialButton(
        minWidth: double.infinity,
        onPressed: () {
          setState(() {
            addDynamicObstacles();
            selectedButtonIndex = 0; // Track that the "Add Obstacles" button was clicked
          });
        },
        color: Colors.white,
        textColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: selectedButtonIndex == 0 ? Colors.blue : Colors.transparent,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: const Text("Add Obstacles"),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  findShortestPath(HeuristicType.chebyshevDistance);
                  selectedButtonIndex = 1; // Track that the "chebyshev" button was clicked
                });
              },
              color: Colors.white,
              textColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: selectedButtonIndex == 1 ? Colors.blue : Colors.transparent,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text("chebyshev"),
            ),
          ),
          const SizedBox(width: 8,),
          Expanded(
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  findShortestPath(HeuristicType.euclideanDistance);
                  selectedButtonIndex = 2; // Track that the "euclidean" button was clicked
                });
              },
              color: Colors.white,
              textColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: selectedButtonIndex == 2 ? Colors.blue : Colors.transparent,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text("euclidean"),
            ),
          ),
          const SizedBox(width: 8,),
          Expanded(
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  findShortestPath(HeuristicType.manhattanDistance);
                  selectedButtonIndex = 3; // Track that the "manhattan" button was clicked
                });
              },
              color: Colors.white,
              textColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: selectedButtonIndex == 3 ? Colors.blue : Colors.transparent,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text("manhattan"),
            ),
          ),
        ],
      ),
      MaterialButton(
        minWidth: double.infinity,
        onPressed: () {
          setState(() {
            reset();
            selectedButtonIndex = 4; // Track that the "Reset" button was clicked
          });
        },
        color: Colors.white,
        textColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: selectedButtonIndex == 4 ? Colors.blue : Colors.transparent,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: const Text("Reset"),
      ),
    ],
  );


}





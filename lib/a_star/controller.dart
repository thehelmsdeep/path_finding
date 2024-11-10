import 'dart:math';
import 'package:bfs_path_finding/a_star/heuristic_methods.dart';
import 'package:bfs_path_finding/a_star/model.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PathfindingController extends ChangeNotifier {

  static const int gridSize = 50;
  List<List<bool>> grid =
      List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));

  Offset? startPoint;
  Offset? endPoint;
  List<Offset> path = [];
  List<Offset> visitedOrder = [];

  int? selectedButtonIndex;

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
      notifyListeners();
      await Future.delayed(const Duration(microseconds: 100));

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
      Offset(0, 1),
      Offset(1, 0),
      Offset(0, -1),
      Offset(-1, 0),
      Offset(1, 1),
      Offset(1, -1),
      Offset(-1, 1),
      Offset(-1, -1)
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

    path.clear();
    visitedOrder.clear();
    notifyListeners();

    path = await aStar(startPoint!, endPoint!, hType);
    notifyListeners();
  }

  void addDynamicObstacles() {
    Random random = Random();
    for (int i = 0; i < 30; i++) {
      int x = random.nextInt(gridSize);
      int y = random.nextInt(gridSize);
      grid[x][y] = true;
    }
    notifyListeners();
  }

  void toggleObstacleAt(Offset point) {
    int row = point.dx.toInt();
    int col = point.dy.toInt();
    grid[row][col] = !grid[row][col];
    notifyListeners();
  }

  void reset() {
    path.clear();
    startPoint = null;
    endPoint = null;
    visitedOrder.clear();
    grid =
        List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));
    notifyListeners();
  }

  void setStartPoint(Offset point) {
    startPoint = point;
    notifyListeners();
  }

  void setEndPoint(Offset point) {
    endPoint = point;
    notifyListeners();
  }

  void setSelectedButtonIndex(int index) {
    selectedButtonIndex = index;
    notifyListeners();
  }
}

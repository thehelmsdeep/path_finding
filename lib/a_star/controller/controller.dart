import 'dart:math';
import 'package:bfs_path_finding/a_star/controller/distance_calculation_methods.dart';
import 'package:bfs_path_finding/a_star/model.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PathfindingController extends ChangeNotifier {

  PathfindingController(){
    onInit();
  }

  bool initialCompleted = false;
  onInit() async {
    grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));
    initialCompleted = true;
    notifyListeners();
  }


  Offset? startPoint;
  Offset? endPoint;
  List<Offset> path = [];
  List<Offset> visitedOrder = [];
  int gridSize = 60;
  late List<List<bool>> grid ;



  void findShortestPath(HeuristicType hType) async {
    if (startPoint == null || endPoint == null) return;

    path.clear();
    visitedOrder.clear();
    notifyListeners();

    path = await _aStar(startPoint!, endPoint!, hType);
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

  void reset() {
    path.clear();
    startPoint = null;
    endPoint = null;
    visitedOrder.clear();
    grid =
        List.generate(gridSize, (i) => List.generate(gridSize, (j) => false));
    notifyListeners();
  }

  void toggleObstacleAt(Offset point) {
    int row = point.dx.toInt();
    int col = point.dy.toInt();
    grid[row][col] = !grid[row][col];
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


  int? selectedButtonIndex;
  void setSelectedButtonIndex(int index) {
    selectedButtonIndex = index;
    notifyListeners();
  }




  Future<List<Offset>> _aStar(
      Offset start, Offset goal, HeuristicType hType) async {
    PriorityQueue<Offset> openSet = PriorityQueue<Offset>();
    Map<Offset, Offset?> cameFrom = {};
    Map<Offset, double> gScore = {};
    Set<Offset> visitedSet = {};

    gScore[start] = 0;
    openSet.add(start, hType.calculateDistance(start, goal));
    cameFrom[start] = null;

    while (!openSet.isEmpty && startPoint != null) {
      Offset current = openSet.removeFirst();
      visitedOrder.add(current);
      notifyListeners();
      await Future.delayed(const Duration(microseconds: 100));

      if (current == goal) {
        return _reconstructPath(cameFrom, current);
      }

      for (Offset neighbor in _getNeighbors(current)) {
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

  List<Offset> _getNeighbors(Offset point) {
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
      if (_isInBounds(neighbor) &&
          !grid[neighbor.dx.toInt()][neighbor.dy.toInt()]) {
        neighbors.add(neighbor);
      }
    }

    return neighbors;
  }

  bool _isInBounds(Offset point) {
    return point.dx >= 0 &&
        point.dx < gridSize &&
        point.dy >= 0 &&
        point.dy < gridSize;
  }

  List<Offset> _reconstructPath(Map<Offset, Offset?> cameFrom, Offset current) {
    List<Offset> path = [current];
    while (cameFrom[current] != null) {
      current = cameFrom[current]!;
      path.add(current);
    }
    return path.reversed.toList();
  }



}

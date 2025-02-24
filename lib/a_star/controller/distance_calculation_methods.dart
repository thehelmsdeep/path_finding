import 'dart:math';
import 'package:flutter/material.dart';




enum HeuristicType {
  manhattanDistance,
  euclideanDistance,
  chebyshevDistance,
}



extension HeuristicExtension on HeuristicType {
  double calculateDistance(Offset pointA, Offset pointB) {
    switch (this) {
      case HeuristicType.manhattanDistance:
        return _manhattanDistance(pointA, pointB);
      case HeuristicType.euclideanDistance:
        return _euclideanDistance(pointA, pointB);
      case HeuristicType.chebyshevDistance:
        return _chebyshevDistance(pointA, pointB);
    }
  }
}



double _manhattanDistance(Offset pointA, Offset pointB) {
  return (pointA.dx - pointB.dx).abs() + (pointA.dy - pointB.dy).abs();
}

double _euclideanDistance(Offset pointA, Offset pointB) {
  return sqrt(pow(pointA.dx - pointB.dx, 2) + pow(pointA.dy - pointB.dy, 2));
}

// Often used when both diagonal and straight moves are allowed
double _chebyshevDistance(Offset pointA, Offset pointB) {
  return max((pointA.dx - pointB.dx).abs(), (pointA.dy - pointB.dy).abs());
}

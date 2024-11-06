import 'dart:math';
import 'package:flutter/material.dart';




// Manhattan distance
double manhattanDistance(Offset pointA, Offset pointB) {
  return (pointA.dx - pointB.dx).abs() + (pointA.dy - pointB.dy).abs();
}

// Euclidean distance
double euclideanDistance(Offset pointA, Offset pointB) {
  return sqrt(pow(pointA.dx - pointB.dx, 2) + pow(pointA.dy - pointB.dy, 2));
}

// Chebyshev distance
// Often used when both diagonal and straight moves are allowed
double chebyshevDistance(Offset pointA, Offset pointB) {
  return max((pointA.dx - pointB.dx).abs(), (pointA.dy - pointB.dy).abs());
}



enum HeuristicType {
  manhattanDistance,
  euclideanDistance,
  chebyshevDistance,
}



extension HeuristicExtension on HeuristicType {
  double calculateDistance(Offset pointA, Offset pointB) {
    switch (this) {
      case HeuristicType.manhattanDistance:
        return manhattanDistance(pointA, pointB);
      case HeuristicType.euclideanDistance:
        return euclideanDistance(pointA, pointB);
      case HeuristicType.chebyshevDistance:
        return chebyshevDistance(pointA, pointB);
    }
  }
}

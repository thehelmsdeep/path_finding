import 'package:bfs_path_finding/a_star/controller.dart';
import 'package:bfs_path_finding/a_star/heuristic_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AStarPathfinder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    final controller = Provider.of<PathfindingController>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                    fontFamily: 'MyCustomFont',
                    color: Colors.grey.shade400,
                    fontSize: 17),
                children: <TextSpan>[
                  TextSpan(
                      text: 'A-star',
                      style: TextStyle(color: Colors.grey.shade600)),
                  const TextSpan(text: ' search algorithm'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            buildGrid(controller),
            const SizedBox(height: 50),
            buildMetrics(controller),
            const SizedBox(height: 50),
            buildButtons(context, controller),
          ],
        ),
      ),
    );
  }




  Widget buildGrid(PathfindingController controller) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: PathfindingController.gridSize,
              childAspectRatio: 0.8,
            ),
            itemCount:
                PathfindingController.gridSize * PathfindingController.gridSize,
            itemBuilder: (context, index) {
              int row = index ~/ PathfindingController.gridSize;
              int col = index % PathfindingController.gridSize;
              Offset point = Offset(row.toDouble(), col.toDouble());

              Color color;
              BoxShape shape = BoxShape.circle;

              if (controller.startPoint == point) {
                color = Colors.orange;
              } else if (controller.endPoint == point) {
                color = Colors.purple;
              } else if (controller.grid[row][col]) {
                color = Colors.grey.shade400;
                shape = BoxShape.rectangle;
              } else if (controller.path.contains(point)) {
                color = Colors.red;
              } else if (controller.visitedOrder.contains(point)) {
                color = Colors.blue.shade200;
              } else {
                color = Colors.white;
              }

              return GestureDetector(
                onTap: () {
                  if (controller.startPoint == null) {
                    controller.setStartPoint(point);
                  } else if (controller.endPoint == null) {
                    controller.setEndPoint(point);
                  } else {
                    controller.toggleObstacleAt(point);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(0.5),
                  decoration: BoxDecoration(color: color, shape: shape),
                ),
              );
            },
          ),
        ),
      ),
    );
  }



  Widget buildMetrics(PathfindingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Visited Points: ${controller.visitedOrder.length}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text('Total Path Points: ${controller.path.length}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      ],
    );
  }



  Widget buildButtons(BuildContext context, PathfindingController controller) {
    return Column(
      children: [
        MaterialButton(
          minWidth: double.infinity,
          onPressed: () {
            controller.addDynamicObstacles();
            controller.setSelectedButtonIndex(0);
          },
          color: Colors.white,
          textColor: Colors.black,
          child: const Text("Add random Obstacles"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildHeuristicButton(
                controller, HeuristicType.chebyshevDistance, "chebyshev", 1),
            const SizedBox(width: 4,),
            buildHeuristicButton(
                controller, HeuristicType.euclideanDistance, "euclidean", 2),
            const SizedBox(width: 4,),
            buildHeuristicButton(
                controller, HeuristicType.manhattanDistance, "manhattan", 3),
          ],
        ),
        MaterialButton(
          minWidth: double.infinity,
          onPressed: () {
            controller.reset();
            controller.setSelectedButtonIndex(4);
          },
          color: Colors.white,
          textColor: Colors.black,
          child: const Text("Reset"),
        ),
      ],
    );
  }

  Widget buildHeuristicButton(PathfindingController controller, HeuristicType heuristic, String label, int index) {
    return Expanded(
      child: MaterialButton(
        onPressed: () {
          controller.findShortestPath(heuristic);
          controller.setSelectedButtonIndex(index);
        },
        color: controller.selectedButtonIndex == index ? Colors.blue : Colors.white,
        textColor: controller.selectedButtonIndex == index ? Colors.white : Colors.black,
        child: Text(label),
      ),
    );
  }

}

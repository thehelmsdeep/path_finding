import 'package:bfs_path_finding/a_star/controller/controller.dart';
import 'package:bfs_path_finding/a_star/controller/distance_calculation_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AStarWidget extends StatelessWidget {
  const AStarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  ChangeNotifierProvider(
        create:(a)=>PathfindingController(),
        child:  const _AStarPathfinderWidget());
  }
}




class _AStarPathfinderWidget extends StatelessWidget {
   const _AStarPathfinderWidget({super.key});

  @override
  Widget build(BuildContext context) {


    final controller = Provider.of<PathfindingController>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Selector<PathfindingController,bool>(
          selector: (a,b)=>b.initialCompleted,
          builder:(a,b,c)=>
              !b ? const CircularProgressIndicator():
              Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 24),
                _buildGrid(controller),
                const SizedBox(height: 40),
                _buildMetrics(controller),
                const SizedBox(height: 40),
                _buildButtons(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }




   Widget _buildTitle() {
     return RichText(
       text: TextSpan(
         style: TextStyle(
           fontFamily: 'MyCustomFont',
           color: Colors.grey.shade400,
           fontSize: 17,
         ),
         children: [
           TextSpan(
             text: 'A-star',
             style: TextStyle(color: Colors.grey.shade600),
           ),
           const TextSpan(text: ' search algorithm'),
         ],
       ),
     );
   }


   Widget _buildGrid(PathfindingController controller) {
     return Padding(
       padding: const EdgeInsets.all(8.0),
       child: GridView.builder(
         shrinkWrap: true,
         physics: const NeverScrollableScrollPhysics(),
         gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: controller.gridSize,
         ),
         itemCount:
         controller.gridSize * controller.gridSize,
         itemBuilder: (context, index) {
           int row = index ~/ controller.gridSize;
           int col = index % controller.gridSize;
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
     );
   }




   Widget _buildMetrics(PathfindingController controller) {
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



  Widget _buildButtons(BuildContext context, PathfindingController controller) {
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
            _buildHeuristicButton(
                controller, HeuristicType.chebyshevDistance, "chebyshev", 1),
            const SizedBox(width: 4,),
            _buildHeuristicButton(
                controller, HeuristicType.euclideanDistance, "euclidean", 2),
            const SizedBox(width: 4,),
            _buildHeuristicButton(
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


  Widget _buildHeuristicButton(PathfindingController controller, HeuristicType heuristic, String label, int index) {
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

import 'package:bfs_path_finding/bfs.dart';
import 'package:flutter/material.dart';


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


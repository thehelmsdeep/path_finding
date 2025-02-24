import 'package:flutter/material.dart';
import 'a_star/view.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Path finder',
      theme: _buildThemeData(),
      home: const AStarWidget(),
    );
  }


  ThemeData _buildThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

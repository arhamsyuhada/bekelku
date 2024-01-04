import 'package:bekelku/pages/mainpage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainPage(),
      theme: ThemeData(primarySwatch: Colors.amber),
      debugShowCheckedModeBanner:
          false, // Set this to false to hide the debug banner
    );
  }
}

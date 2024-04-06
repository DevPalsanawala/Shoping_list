import 'package:flutter/material.dart';
import 'package:shopinglist/widgets/grocery_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Groceries",
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 130, 156, 188),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 29, 52, 97),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(150, 98, 144, 200),
      ),
      home: const GroceryList(),
    );
  }
}

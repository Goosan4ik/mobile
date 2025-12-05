import 'package:flutter/material.dart';
import 'Convert_page/converter.dart';
import 'Convert_page/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converter',
      theme: ThemeData.dark(),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const Home(),
        '/square': (context) => const Converter(),
        '/weight': (context) => const Converter(),
        '/volume': (context) => const Converter(),
        '/distance': (context) => const Converter(),
        '/currency': (context) => const Converter(),
      },
    );
  }
}
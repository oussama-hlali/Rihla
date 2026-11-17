import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rihla/data/destinations.dart';
import 'package:rihla/providers/favoris_model.dart';
import 'package:rihla/screens/detail_screen.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavorisModel(),
      child: const RihlaApp(),
    ),
  );
}

class RihlaApp extends StatelessWidget {
  const RihlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rihla',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7C86)),
      ),

      home: const HomeScreen(),
    );
  }
}

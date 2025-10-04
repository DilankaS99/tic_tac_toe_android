import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_model/game_view_model.dart';
import 'view/landing_screen.dart';

void main() {
  runApp(
    // The ChangeNotifierProvider creates and provides the GameViewModel
    // to all widgets below it in the tree.
    ChangeNotifierProvider(
      create: (_) => GameViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,

         fontFamily: 'Montserrat',

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.9),
            foregroundColor: Colors.black,
          )
        )
      ),
      home: const LandingScreen(),
    );
  }
}


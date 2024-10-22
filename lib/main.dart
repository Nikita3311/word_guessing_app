import 'package:flutter/material.dart';
import 'screens/word_guessing_game.dart'; // Import the file containing WordGuessingGame


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Guessing Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WordGuessingGame(), // Directly load your main game screen
    );
  }
}

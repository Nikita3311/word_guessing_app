import 'package:flutter/material.dart';
import 'screens/word_guessing_game.dart'; // Import the file containing WordGuessingGame
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:async'; // For handling the delay


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
      home: SplashScreen(), // Use the widget from another file
    );
  }
}
// splash screen class
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Using WidgetsBinding to ensure the navigation happens after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a delay of 3 seconds
      Timer(Duration(seconds: 3), () {
        // After delay, navigate to WordGuessingGame screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => WordGuessingGame(),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2196F3), // Set your desired background color
      body: Center(
        child: Image.asset('assets/W.png', width: 200, height: 200), // Your custom splash image
      ),
    );
  }
}

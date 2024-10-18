import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';  // Required for path management
import '../database_helper.dart'; // Import the database helper
import '../word_dictionary.dart';  // Import the main dictionary
import '../learning_dictionary.dart';  // Import the learning dictionary
import '../screens/learning_list_screen.dart';
import '../screens/practice.dart';
import 'package:google_fonts/google_fonts.dart';

class WordGuessingGame extends StatefulWidget {
  @override
  _WordGuessingGameState createState() => _WordGuessingGameState();
}

class _WordGuessingGameState extends State<WordGuessingGame> {
  String currentEnglishWord = '';
  String currentRussianTranslation = '';
  bool _isLoading = true;  // Loading state for fetching words
  Random random = Random();

  // Database helper instance
  final dbHelper = DatabaseHelper.getInstance();

  @override
  void initState() {
    super.initState();
    initializeUserDatabase();  // Initialize user-specific database
  }

  // Initialize the user-specific database
  Future<void> initializeUserDatabase() async {
    setState(() {
      _isLoading = true;  // Start loading
    });

    await dbHelper.initializeUserDatabase();  // Initialize the user-specific database
    await getRandomWord();  // Load a random word

    setState(() {
      _isLoading = false;  // Stop loading once the data is ready
    });
  }

  // Function to get a random word and its translation from the initial_words.db
  Future<void> getRandomWord() async {
    try {
      Map<String, dynamic> word = await dbHelper.getRandomWordFromInitialWords();
      setState(() {
        currentEnglishWord = word['english'];
        currentRussianTranslation = word['russian'];
      });
    } catch (e) {
      print("Error fetching random word: $e");
      setState(() {
        currentEnglishWord = 'Error fetching word';
        currentRussianTranslation = '';
      });
    }
  }

  // Function to add the current word to the learning database
  void addToLearningDatabase() async {
    await dbHelper.insertWordToLearning(currentEnglishWord, currentRussianTranslation);
    print('Word added: $currentEnglishWord -> $currentRussianTranslation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Add the list icon in the right corner
          IconButton(
            icon: Icon(Icons.list),  // Use list icon
            tooltip: 'My Learning List',
            onPressed: () {
              // Navigate to the Learning List Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LearningListScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    currentEnglishWord,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    currentRussianTranslation,
                    textAlign: TextAlign.center,  // Ensure the text is center-aligned
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontSize: 36,
                        color: Colors.grey,  //
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Row widget to place buttons side by side
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: getRandomWord,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.white,  // White background
                        ),
                        child: Text(
                          'Дальше',
                          style: GoogleFonts.montserrat(  // Applying Montserrat font
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,  // Set text color to blue
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),  // Space between buttons
                      ElevatedButton(
                        onPressed: () {
                          addToLearningDatabase();  // Add word to learning database
                          getRandomWord();  // Get the next word after adding
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),  // Circular button
                          padding: EdgeInsets.all(15),
                          backgroundColor: Colors.white,  // White background
                        ),
                        child: Icon(
                          Icons.favorite_border,  // Heart icon for "Add to Favorite"
                          color: Colors.blue,     // Blue icon color
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Add the "Practice" button at the bottom
            ElevatedButton(
              style: ElevatedButton.styleFrom(

                backgroundColor: Colors.blue,  // Button background color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: GoogleFonts.montserrat(
                  fontSize: 20,
                  color: Colors.white,  // White text
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PracticeScreen()),  // Navigate to Practice Screen
                );
              },
                child: Text(
                  'Проверка',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,  // White text color
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}




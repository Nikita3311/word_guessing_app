import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class PracticeScreen extends StatefulWidget {
  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String currentEnglishWord = '';
  String currentRussianTranslation = '';
  bool showTranslation = false;  // Track if the card should show the translation
  final dbHelper = DatabaseHelper.getInstance();
  Random random = Random();

  List<Map<String, dynamic>> learningWords = [];

  @override
  void initState() {
    super.initState();
    loadLearningWords();  // Load words from the learning list
  }

  // Load words from the learning list (learning_words table)
  Future<void> loadLearningWords() async {
    List<Map<String, dynamic>> words = await dbHelper.getLearningWords();
    setState(() {
      learningWords = words;
    });
    getRandomWord();  // Display a random word
  }

  // Function to get a random word and its translation from the learning list
  void getRandomWord() {
    if (learningWords.isNotEmpty) {
      int randomIndex = random.nextInt(learningWords.length);
      setState(() {
        currentEnglishWord = learningWords[randomIndex]['english'];
        currentRussianTranslation = learningWords[randomIndex]['russian'];
        showTranslation = false;  // Reset to show the English word when a new word is displayed
      });
    } else {
      setState(() {
        currentEnglishWord = 'No words available';
        currentRussianTranslation = '';
      });
    }
  }

  // Toggle to show the translation when the card is clicked
  void showWordTranslation() {
    setState(() {
      showTranslation = true;  // Set to show the translation
    });
  }

  // Handle "Right" button click to increment guess count
  Future<void> handleRightButton() async {
    // Increment the number_of_guesses for the current word
    await dbHelper.incrementGuessCount(currentEnglishWord);

    // Fetch the updated guess count
    int guessCount = await dbHelper.getGuessCount(currentEnglishWord);
    print('Guess count for "$currentEnglishWord": $guessCount');  // Debugging line

    if (guessCount >= 3) {
      // If guess count reaches 3, remove the word from the learning list
      await dbHelper.deleteUserWord(currentEnglishWord);

      // Show notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Отлично! Слово "$currentEnglishWord" выучено! Удаляем его из списка',
            style: TextStyle(fontSize: 18),  // Увеличение размера шрифта
          ),
          behavior: SnackBarBehavior.floating,  // Сделать снекбар плавающим (опционально)
          margin: EdgeInsets.all(20),  // Добавить отступы со всех сторон
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),  // Увеличить внутренние отступы
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),  // Скруглённые углы
          ),
          backgroundColor: Colors.blueAccent,  // Цвет фона (опционально)
        ),
      );

      // Reload learning words and fetch the next random word
      await loadLearningWords();
    } else {
      // Fetch the next random word if guess count is less than 3
      getRandomWord();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentEnglishWord.isNotEmpty) ...[
                GestureDetector(
                  onTap: showWordTranslation, // Show the translation when tapped
                  child: SizedBox(
                    width: 300,  // Fixed width for the card
                    height: 150,  // Fixed height for the card
                    child: Card(
                      color: showTranslation ? Colors.blue : Colors.white,  // Change color if translation is shown
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          showTranslation ? currentRussianTranslation : currentEnglishWord,  // Show translation if tapped
                          style: GoogleFonts.montserrat(  // Apply Montserrat font
                            textStyle: TextStyle(
                              fontSize: 36,
                              color: showTranslation ? Colors.white : Colors.black,  // Text color changes for better readability
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Round button for "Wrong"
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,  // Red background
                        shape: BoxShape.circle,  // Circle shape
                      ),
                      child: IconButton(
                        onPressed: getRandomWord,
                        icon: Icon(Icons.close, color: Colors.white),  // White icon
                        iconSize: 30,  // Adjust icon size
                        tooltip: 'Wrong',  // Tooltip for accessibility
                      ),
                    ),
                    SizedBox(width: 70),  // Increased space between buttons
                    // Round button for "Right"
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,  // Green background
                        shape: BoxShape.circle,  // Circle shape
                      ),
                      child: IconButton(
                        onPressed: handleRightButton,
                        icon: Icon(Icons.check, color: Colors.white),  // White icon
                        iconSize: 30,  // Adjust icon size
                        tooltip: 'Right',  // Tooltip for accessibility
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  'No words to practice yet.',
                  style: GoogleFonts.montserrat(  // Apply Montserrat font
                    textStyle: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../database_helper.dart';  // Adjust path based on where DatabaseHelper is
import 'package:google_fonts/google_fonts.dart';

class LearningListScreen extends StatelessWidget {
  final dbHelper = DatabaseHelper.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Мои слова',
          style: GoogleFonts.montserrat(
            fontSize: 20, // Font size for AppBar title
            fontWeight: FontWeight.bold,
            color: Colors.black, // Text color for AppBar
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getLearningWords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.montserrat( // Montserrat for error text
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Пока пусто :(',
                style: GoogleFonts.montserrat( // Montserrat for empty state
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                ),
              ),
            );
          }

          // Display the list of words
          List<Map<String, dynamic>> words = snapshot.data!;
          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return ListTile(
                title: Text(
                  word['english'],
                  style: GoogleFonts.montserrat( // Montserrat for English word
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  word['russian'],
                  style: GoogleFonts.montserrat( // Montserrat for Russian word
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
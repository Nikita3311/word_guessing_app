import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;  // To load assets
import 'dart:io';  // For file operations
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'dart:math';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  Database? _userDatabase;  // Local user database for learning_words
  Database? _initialWordsDatabase;  // Separate DB for initial_words
  String? _currentUserId;

  // Private constructor
  DatabaseHelper._internal();

  // Singleton pattern
  static DatabaseHelper getInstance() {
    if (_instance == null) {
      _instance = DatabaseHelper._internal();
    }
    return _instance!;
  }

  // Initialize user-specific database (called on app startup)
  Future<void> initializeUserDatabase() async {
    _currentUserId = await _getOrCreateUserId();  // Get or create a user ID
    _userDatabase = await _initUserDatabase(_currentUserId!);  // Initialize the local user database
  }

  // Get the user ID from SharedPreferences or create a new one
  Future<String> _getOrCreateUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      userId = Uuid().v4();  // Create a new user ID using UUID
      await prefs.setString('userId', userId);  // Store the new user ID
    }

    return userId;
  }

  // Initialize the local user-specific database (only for learning_words)
  Future<Database> _initUserDatabase(String userId) async {
    String path = join(await getDatabasesPath(), 'user_$userId.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateUserDb,  // Create learning_words table
    );
  }

  // Create the learning_words table
  Future _onCreateUserDb(Database db, int version) async {
    print("Creating learning_words table...");
    await db.execute('''
      CREATE TABLE learning_words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        english TEXT,
        russian TEXT,
        number_of_guesses INTEGER DEFAULT 0
      )
    ''');
    print("Created learning_words table.");
  }

  // Access the global initial_words.db for word dictionary
  Future<void> _openInitialWordsDatabase() async {
    if (_initialWordsDatabase != null) return;  // Already opened

    ByteData data = await rootBundle.load('assets/initial_words.db');
    List<int> bytes = data.buffer.asUint8List();

    String tempDbPath = join(await getDatabasesPath(), 'initial_words.db');
    await File(tempDbPath).writeAsBytes(bytes, flush: true);

    _initialWordsDatabase = await openDatabase(tempDbPath);
    print("Opened initial_words database.");
  }

  // Function to fetch a random word from the initial_words.db
  Future<Map<String, dynamic>> getRandomWordFromInitialWords() async {
    await _openInitialWordsDatabase();  // Ensure the initial_words.db is open

    final List<Map<String, dynamic>> words = await _initialWordsDatabase!.query('word_dictionary');
    if (words.isNotEmpty) {
      final randomIndex = Random().nextInt(words.length);  // Get random index
      return words[randomIndex];  // Return the random word
    } else {
      throw Exception("No words available in the initial_words.db.");
    }
  }

  // Insert a word into the user's local learning_words table
  Future<void> insertWordToLearning(String english, String russian) async {
    final db = await _userDatabase;
    await db!.insert('learning_words', {
      'english': english,
      'russian': russian,
    });
  }

  // Get all words from the learning_words table (locally stored)
  Future<List<Map<String, dynamic>>> getLearningWords() async {
    final db = await _userDatabase;
    return await db!.query('learning_words');
  }
  // Increment the number_of_guesses for a word
  Future<void> incrementGuessCount(String english) async {
    final db = await _userDatabase;
    await db!.execute('''
      UPDATE learning_words SET number_of_guesses = number_of_guesses + 1 WHERE english = ?
    ''', [english]);
  }

  // Get the number_of_guesses for a specific word
  Future<int> getGuessCount(String english) async {
    final db = await _userDatabase;
    final List<Map<String, dynamic>> result = await db!.query(
        'learning_words',
        columns: ['number_of_guesses'],
        where: 'english = ?',
        whereArgs: [english]
    );

    if (result.isNotEmpty) {
      return result.first['number_of_guesses'] as int;
    } else {
      return 0;  // Default if the word isn't found
    }
  }

  // Function to delete a word from the user's local learning_words table
  Future<void> deleteUserWord(String english) async {
    final db = await _userDatabase;
    await db!.delete('learning_words', where: 'english = ?', whereArgs: [english]);
    print("Word deleted: $english");
  }
}




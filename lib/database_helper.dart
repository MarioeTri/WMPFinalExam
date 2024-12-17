import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_data.db');
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, path);
    return await openDatabase(fullPath, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        id_number TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE enrollments(
        user_id INTEGER,
        subject TEXT,
        credits INTEGER,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('users', row);
  }

  Future<List<Map<String, dynamic>>> queryUser(String email) async {
    Database db = await instance.database;
    return await db.query('users', where: 'email = ?', whereArgs: [email]);
  }

  Future<List<Map<String, dynamic>>> queryEnrollments(int userId) async {
    Database db = await instance.database;
    return await db.query('enrollments', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> insertEnrollment(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('enrollments', row);
  }
}

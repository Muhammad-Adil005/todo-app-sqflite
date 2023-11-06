import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();

  static Database? _db = null;

  DatabaseHelper._instance();

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  /*
  This is how our Note Table look like

  id | Title | Date | Priority | Status
  0   ...............................
  1   ...............................
   */

  // Here we check the condition if there is no Database then we create a Database and If there is a Database
  // then we simply return it
  Future<Database?> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  // This Function will initialize the database
  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'todo_list.db';
    final todoListDB =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDB;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER )');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(noteTable);
    return result;
  }

  // This Function get the List of the how much list are there inside a Database
  Future<List<Note>> getNoteList() async {
    final List<Map<String, dynamic>> noteMapList = await getNoteMapList();

    final List<Note> noteList = [];
    noteMapList.forEach((noteMap) {
      noteList.add(Note.fromMap(noteMap));
    });
    noteList.sort((noteA, noteB) => noteA.date!.compareTo(noteB.date!));
    return noteList;
  }

  // This function is for to insert a Note inside  the Database

  Future<int> insertNote(Note note) async {
    Database? db = await this.db;
    final int result = await db!.insert(
      noteTable,
      note.toMap(),
    );
    return result;
  }

  // This function is for to update a Note inside the Database

  Future<int> updateNote(Note note) async {
    Database? db = await this.db;
    final int result = await db!.update(
      noteTable,
      note.toMap(),
      where: '$colId = ?',
      whereArgs: [note.id],
    );
    return result;
  }

// This function is for to delete a Note from the Database
  Future<int> deleteNote(int id) async {
    Database? db = await this.db;
    final int result = await db!.delete(
      noteTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }
}

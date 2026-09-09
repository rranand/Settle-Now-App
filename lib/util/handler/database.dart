import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHandler {
  static Database? _database;

  static const int _databaseVersion = 1;

  static Future<void> initialize() async {
    if (kIsWeb || _database != null) return;
    unawaited(_open());
  }

  static Future<Database> get database async {
    if (kIsWeb) {
      throw Exception('Database is not supported on web');
    }

    if (_database != null) return _database!;
    await _open();
    return _database!;
  }

  static Future<void> _open() async {
    if (kIsWeb || _database != null) {
      return;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'settlenow.db');

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE bank_transaction_consumed (
        id TEXT PRIMARY KEY,              -- content hash from BankTransactionModel
        room_type TEXT NOT NULL,          -- RoomType as string
        room_id TEXT NOT NULL,            -- Room ID as string
        transaction_id TEXT              -- Transaction ID as string     
      )
    ''');

    batch.execute('''
      CREATE INDEX idx_bank_id ON bank_transaction_consumed(id);
    ''');

    await batch.commit(noResult: true);
  }

  // static Future<void> _onUpgrade(
  //   Database db,
  //   int oldVersion,
  //   int newVersion,
  // ) async {
  //   if (oldVersion < 2) {
  //     await _createUserTable(db);
  //   }

  //   // Future migrations:
  //   //
  //   // if (oldVersion < 3) {
  //   //   await _createSomethingTable(db);
  //   // }
  // }
}

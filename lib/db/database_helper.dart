import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DatabaseHelper {
  //Singleton para la base de datos (para una única instancia)
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database; //Instancia de la base de datos

  DatabaseHelper._internal(); //Constructor privado

  //Getter para acceder a la db (inicializa si es necesario)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  //Inicializa la db
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath); //Ruta de la base de datos

    //Crea la tabla al iniciarla por primera vez
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //Crea la estructura de la tabla
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        category TEXT,
        amount REAL,
        date TEXT
      )
    ''');
  }

//OPERACIONES CRUD

  //Inserta nuevo gasto
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  //Obtiene los gastos ordenados por fecha
  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  //Actualiza un gasto existente
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  //Elimina un gasto existente por su ID
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}

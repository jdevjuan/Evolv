import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/day_data.dart';
import '../models/exercise_entry.dart';
import '../models/food_entry.dart';
import '../models/goals.dart';
import '../models/user_profile.dart';
import '../models/water_entry.dart';
import '../models/weight_entry.dart';

/// Acesso ao banco SQLite local. Todas as consultas ficam aqui,
/// assim as telas nunca escrevem SQL diretamente.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _database;
  Future<Database> get _db async => _database ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'evolv.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        height_cm REAL NOT NULL,
        weight_kg REAL NOT NULL,
        objective TEXT
      )''');
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY,
        target_weight REAL NOT NULL,
        daily_calories INTEGER NOT NULL,
        daily_water_ml INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        portion TEXT NOT NULL,
        calories INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE water (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ml INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        minutes INTEGER NOT NULL,
        date TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE weights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kg REAL NOT NULL,
        date TEXT NOT NULL
      )''');
    for (final table in ['foods', 'water', 'exercises', 'weights']) {
      await db.execute('CREATE INDEX idx_${table}_date ON $table(date)');
    }
  }

  // ---------- Perfil e metas (sempre 1 linha, id = 1) ----------

  Future<UserProfile?> getProfile() async {
    final rows = await (await _db).query('user_profile', limit: 1);
    return rows.isEmpty ? null : UserProfile.fromMap(rows.first);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await (await _db).insert('user_profile', profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Goals?> getGoals() async {
    final rows = await (await _db).query('goals', limit: 1);
    return rows.isEmpty ? null : Goals.fromMap(rows.first);
  }

  Future<void> saveGoals(Goals goals) async {
    await (await _db).insert('goals', goals.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---------- Alimentos ----------

  Future<void> addFood(FoodEntry e) async => (await _db).insert('foods', e.toMap());
  Future<void> deleteFood(int id) async => (await _db).delete('foods', where: 'id = ?', whereArgs: [id]);

  Future<List<FoodEntry>> foodsByDate(String date) async {
    final rows = await (await _db).query('foods', where: 'date = ?', whereArgs: [date], orderBy: 'time DESC, id DESC');
    return rows.map(FoodEntry.fromMap).toList();
  }

  // ---------- Água ----------

  Future<void> addWater(WaterEntry e) async => (await _db).insert('water', e.toMap());
  Future<void> deleteWater(int id) async => (await _db).delete('water', where: 'id = ?', whereArgs: [id]);

  Future<List<WaterEntry>> waterByDate(String date) async {
    final rows = await (await _db).query('water', where: 'date = ?', whereArgs: [date], orderBy: 'time DESC, id DESC');
    return rows.map(WaterEntry.fromMap).toList();
  }

  // ---------- Exercícios ----------

  Future<void> addExercise(ExerciseEntry e) async => (await _db).insert('exercises', e.toMap());
  Future<void> deleteExercise(int id) async => (await _db).delete('exercises', where: 'id = ?', whereArgs: [id]);

  Future<List<ExerciseEntry>> exercisesByDate(String date) async {
    final rows = await (await _db).query('exercises', where: 'date = ?', whereArgs: [date], orderBy: 'id DESC');
    return rows.map(ExerciseEntry.fromMap).toList();
  }

  Future<List<ExerciseEntry>> exercisesSince(String since) async {
    final rows = await (await _db).query('exercises', where: 'date >= ?', whereArgs: [since], orderBy: 'date DESC, id DESC');
    return rows.map(ExerciseEntry.fromMap).toList();
  }

  // ---------- Peso (no máximo 1 registro por dia) ----------

  Future<void> upsertWeight(String date, double kg) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('weights', where: 'date = ?', whereArgs: [date]);
      await txn.insert('weights', WeightEntry(kg: kg, date: date).toMap());
    });
  }

  Future<List<WeightEntry>> weightsSince(String since) async {
    final rows = await (await _db).query('weights', where: 'date >= ?', whereArgs: [since], orderBy: 'date ASC');
    return rows.map(WeightEntry.fromMap).toList();
  }

  Future<WeightEntry?> weightByDate(String date) async {
    final rows = await (await _db).query('weights', where: 'date = ?', whereArgs: [date], limit: 1);
    return rows.isEmpty ? null : WeightEntry.fromMap(rows.first);
  }

  // ---------- Séries para os gráficos (soma por dia) ----------

  Future<Map<String, int>> _sumByDay(String table, String column, String since) async {
    final rows = await (await _db).rawQuery(
      'SELECT date, SUM($column) AS total FROM $table WHERE date >= ? GROUP BY date',
      [since],
    );
    return {for (final r in rows) r['date'] as String: (r['total'] as num).toInt()};
  }

  Future<Map<String, int>> caloriesByDay(String since) => _sumByDay('foods', 'calories', since);
  Future<Map<String, int>> waterByDay(String since) => _sumByDay('water', 'ml', since);
  Future<Map<String, int>> minutesByDay(String since) => _sumByDay('exercises', 'minutes', since);

  // ---------- Histórico ----------

  /// Datas que possuem pelo menos um registro, da mais recente para a mais antiga.
  Future<List<String>> historyDates({int limit = 120}) async {
    final rows = await (await _db).rawQuery('''
      SELECT date FROM foods
      UNION SELECT date FROM water
      UNION SELECT date FROM exercises
      UNION SELECT date FROM weights
      ORDER BY date DESC
      LIMIT ?''', [limit]);
    return rows.map((r) => r['date'] as String).toList();
  }

  Future<DayData> dayData(String date) async {
    return DayData(
      foods: await foodsByDate(date),
      water: await waterByDate(date),
      exercises: await exercisesByDate(date),
      weight: await weightByDate(date),
    );
  }
}

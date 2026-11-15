import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../models/exercise_entry.dart';
import '../models/food_entry.dart';
import '../models/goals.dart';
import '../models/user_profile.dart';
import '../models/water_entry.dart';
import '../utils/formatters.dart';

/// Guarda o estado do dia atual e expõe as ações do app.
/// Toda ação grava no SQLite, recarrega os dados e avisa as telas (notifyListeners),
/// por isso o Dashboard se atualiza sozinho depois de cada registro.
class AppController extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;

  UserProfile? profile;
  Goals? goals;
  List<FoodEntry> foods = [];
  List<WaterEntry> water = [];
  List<ExerciseEntry> recentExercises = []; // últimos 30 dias
  String _loadedDay = '';

  int get totalCalories => foods.fold(0, (sum, e) => sum + e.calories);
  int get totalWater => water.fold(0, (sum, e) => sum + e.ml);

  List<ExerciseEntry> get todayExercises {
    final today = todayKey();
    return recentExercises.where((e) => e.date == today).toList();
  }

  int get todayMinutes => todayExercises.fold(0, (sum, e) => sum + e.minutes);

  int get weekMinutes {
    final since = dateKey(daysAgo(6));
    return recentExercises.where((e) => e.date.compareTo(since) >= 0).fold(0, (sum, e) => sum + e.minutes);
  }

  Future<void> load() async {
    final today = todayKey();
    profile = await _db.getProfile();
    goals = await _db.getGoals();
    foods = await _db.foodsByDate(today);
    water = await _db.waterByDate(today);
    recentExercises = await _db.exercisesSince(dateKey(daysAgo(29)));
    _loadedDay = today;
    notifyListeners();
  }

  /// Chamado quando o app volta ao primeiro plano: se virou o dia, recarrega.
  Future<void> refreshIfNewDay() async {
    if (_loadedDay != todayKey()) await load();
  }

  // ---------- Perfil e metas ----------

  Future<void> saveProfile(UserProfile p) async {
    final previous = profile;
    await _db.saveProfile(p);
    // Só cria um novo ponto no histórico de peso se o peso realmente mudou.
    if (previous == null || previous.weightKg != p.weightKg) {
      await _db.upsertWeight(todayKey(), p.weightKg);
    }
    await load();
  }

  Future<void> saveGoals(Objective objective, Goals g) async {
    await _db.saveGoals(g);
    final current = profile;
    if (current != null) await _db.saveProfile(current.copyWith(objective: objective));
    await load();
  }

  Future<void> registerWeight(double kg) async {
    await _db.upsertWeight(todayKey(), kg);
    final current = profile;
    if (current != null) await _db.saveProfile(current.copyWith(weightKg: kg));
    await load();
  }

  // ---------- Registros ----------

  Future<void> addFood(String name, String portion, int calories) async {
    await _db.addFood(FoodEntry(name: name, portion: portion, calories: calories, date: todayKey(), time: timeNow()));
    await load();
  }

  Future<void> deleteFood(int id) async {
    await _db.deleteFood(id);
    await load();
  }

  Future<void> addWater(int ml) async {
    await _db.addWater(WaterEntry(ml: ml, date: todayKey(), time: timeNow()));
    await load();
  }

  Future<void> deleteWater(int id) async {
    await _db.deleteWater(id);
    await load();
  }

  Future<void> addExercise(String name, int minutes, String date) async {
    await _db.addExercise(ExerciseEntry(name: name, minutes: minutes, date: date));
    await load();
  }

  Future<void> deleteExercise(int id) async {
    await _db.deleteExercise(id);
    await load();
  }
}

/// Instância única usada por todo o app.
final AppController appController = AppController();

import 'exercise_entry.dart';
import 'food_entry.dart';
import 'water_entry.dart';
import 'weight_entry.dart';

/// Tudo o que foi registrado em um único dia (usado no Histórico).
class DayData {
  const DayData({required this.foods, required this.water, required this.exercises, this.weight});

  final List<FoodEntry> foods;
  final List<WaterEntry> water;
  final List<ExerciseEntry> exercises;
  final WeightEntry? weight;

  int get calories => foods.fold(0, (sum, e) => sum + e.calories);
  int get waterMl => water.fold(0, (sum, e) => sum + e.ml);
  int get minutes => exercises.fold(0, (sum, e) => sum + e.minutes);
}

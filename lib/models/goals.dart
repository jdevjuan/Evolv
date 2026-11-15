class Goals {
  const Goals({required this.targetWeight, required this.dailyCalories, required this.dailyWaterMl});

  final double targetWeight;
  final int dailyCalories;
  final int dailyWaterMl;

  Map<String, Object?> toMap() => {
        'id': 1,
        'target_weight': targetWeight,
        'daily_calories': dailyCalories,
        'daily_water_ml': dailyWaterMl,
      };

  factory Goals.fromMap(Map<String, Object?> m) => Goals(
        targetWeight: (m['target_weight'] as num).toDouble(),
        dailyCalories: m['daily_calories'] as int,
        dailyWaterMl: m['daily_water_ml'] as int,
      );
}

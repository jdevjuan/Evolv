class FoodEntry {
  const FoodEntry({this.id, required this.name, required this.portion, required this.calories, required this.date, required this.time});

  final int? id;
  final String name;
  final String portion;
  final int calories;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'portion': portion,
        'calories': calories,
        'date': date,
        'time': time,
      };

  factory FoodEntry.fromMap(Map<String, Object?> m) => FoodEntry(
        id: m['id'] as int,
        name: m['name'] as String,
        portion: m['portion'] as String,
        calories: m['calories'] as int,
        date: m['date'] as String,
        time: m['time'] as String,
      );
}

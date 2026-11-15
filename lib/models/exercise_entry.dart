class ExerciseEntry {
  const ExerciseEntry({this.id, required this.name, required this.minutes, required this.date});

  final int? id;
  final String name;
  final int minutes;
  final String date;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'minutes': minutes,
        'date': date,
      };

  factory ExerciseEntry.fromMap(Map<String, Object?> m) => ExerciseEntry(
        id: m['id'] as int,
        name: m['name'] as String,
        minutes: m['minutes'] as int,
        date: m['date'] as String,
      );
}

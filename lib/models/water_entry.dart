class WaterEntry {
  const WaterEntry({this.id, required this.ml, required this.date, required this.time});

  final int? id;
  final int ml;
  final String date;
  final String time;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'ml': ml,
        'date': date,
        'time': time,
      };

  factory WaterEntry.fromMap(Map<String, Object?> m) => WaterEntry(
        id: m['id'] as int,
        ml: m['ml'] as int,
        date: m['date'] as String,
        time: m['time'] as String,
      );
}

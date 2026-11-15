class WeightEntry {
  const WeightEntry({this.id, required this.kg, required this.date});

  final int? id;
  final double kg;
  final String date;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'kg': kg,
        'date': date,
      };

  factory WeightEntry.fromMap(Map<String, Object?> m) => WeightEntry(
        id: m['id'] as int,
        kg: (m['kg'] as num).toDouble(),
        date: m['date'] as String,
      );
}

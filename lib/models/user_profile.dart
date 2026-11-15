enum Objective {
  lose('Emagrecer'),
  gain('Ganhar peso'),
  muscle('Ganhar massa muscular'),
  maintain('Manter o peso atual');

  const Objective(this.label);
  final String label;

  static Objective? fromName(String? name) {
    for (final o in values) {
      if (o.name == name) return o;
    }
    return null;
  }
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    this.objective,
  });

  final String name;
  final int age;
  final double heightCm;
  final double weightKg;
  final Objective? objective;

  UserProfile copyWith({String? name, int? age, double? heightCm, double? weightKg, Objective? objective}) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      objective: objective ?? this.objective,
    );
  }

  Map<String, Object?> toMap() => {
        'id': 1,
        'name': name,
        'age': age,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'objective': objective?.name,
      };

  factory UserProfile.fromMap(Map<String, Object?> m) => UserProfile(
        name: m['name'] as String,
        age: m['age'] as int,
        heightCm: (m['height_cm'] as num).toDouble(),
        weightKg: (m['weight_kg'] as num).toDouble(),
        objective: Objective.fromName(m['objective'] as String?),
      );
}

class Child {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final String language;
  final double age;
  final DateTime createdAt;
  final String? hospitalId;

  Child({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.language,
    required this.age,
    required this.createdAt,
    this.hospitalId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
      'gender': gender,
      'language': language,
      'age': age,
      'created_at': createdAt.millisecondsSinceEpoch,
      'hospital_id': hospitalId,
    };
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(json['date_of_birth'] as int),
      gender: json['gender'] as String,
      language: json['language'] as String,
      age: (json['age'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      hospitalId: json['hospital_id'] as String?,
    );
  }

  Child copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? language,
    double? age,
    DateTime? createdAt,
    String? hospitalId,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      language: language ?? this.language,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
      hospitalId: hospitalId ?? this.hospitalId,
    );
  }
}


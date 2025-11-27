/// Child profile model for autism screening pilot study
/// 
/// Captures data for both ASD group (clinical diagnosis) and 
/// Control group (typically developing children from preschools)
class Child {
  final String id;
  final String childCode; // e.g., LRH-027, PRE-112
  final String name;
  final DateTime dateOfBirth;
  final int ageInMonths;
  final String gender;
  final String language;
  final double age; // Age in years (decimal)
  final DateTime createdAt;
  final String? hospitalId;
  
  // Study-specific fields
  final ChildGroup group; // ASD or Typically Developing
  final AsdLevel? asdLevel; // Only for ASD group
  final String diagnosisSource; // Hospital name or "Preschool screening"

  Child({
    required this.id,
    required this.childCode,
    required this.name,
    required this.dateOfBirth,
    required this.ageInMonths,
    required this.gender,
    required this.language,
    required this.age,
    required this.createdAt,
    this.hospitalId,
    required this.group,
    this.asdLevel,
    required this.diagnosisSource,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_code': childCode,
      'name': name,
      'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
      'age_in_months': ageInMonths,
      'gender': gender,
      'language': language,
      'age': age,
      'created_at': createdAt.millisecondsSinceEpoch,
      'hospital_id': hospitalId,
      'group': group.toJson(),
      'asd_level': asdLevel?.toJson(),
      'diagnosis_source': diagnosisSource,
    };
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      childCode: json['child_code'] as String? ?? json['name'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(json['date_of_birth'] as int),
      ageInMonths: json['age_in_months'] as int? ?? _calculateAgeInMonths(
        DateTime.fromMillisecondsSinceEpoch(json['date_of_birth'] as int),
      ),
      gender: json['gender'] as String,
      language: json['language'] as String,
      age: (json['age'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      hospitalId: json['hospital_id'] as String?,
      group: ChildGroup.fromJson(json['group'] as String? ?? 'typically_developing'),
      asdLevel: json['asd_level'] != null 
          ? AsdLevel.fromJson(json['asd_level'] as String)
          : null,
      diagnosisSource: json['diagnosis_source'] as String? ?? 'Unknown',
    );
  }

  Child copyWith({
    String? id,
    String? childCode,
    String? name,
    DateTime? dateOfBirth,
    int? ageInMonths,
    String? gender,
    String? language,
    double? age,
    DateTime? createdAt,
    String? hospitalId,
    ChildGroup? group,
    AsdLevel? asdLevel,
    String? diagnosisSource,
  }) {
    return Child(
      id: id ?? this.id,
      childCode: childCode ?? this.childCode,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      gender: gender ?? this.gender,
      language: language ?? this.language,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
      hospitalId: hospitalId ?? this.hospitalId,
      group: group ?? this.group,
      asdLevel: asdLevel ?? this.asdLevel,
      diagnosisSource: diagnosisSource ?? this.diagnosisSource,
    );
  }

  static int _calculateAgeInMonths(DateTime dob) {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months;
  }

  /// Get display string for the child's group
  String get groupDisplayName => group == ChildGroup.asd ? 'ASD' : 'Typically Developing';

  /// Get display string for ASD level (if applicable)
  String? get asdLevelDisplayName => asdLevel?.displayName;

  /// Check if this child is in the ASD group
  bool get isAsdGroup => group == ChildGroup.asd;

  /// Check if this child is in the control (TD) group
  bool get isControlGroup => group == ChildGroup.typicallyDeveloping;
}

/// Represents the study group for a child
enum ChildGroup {
  asd,
  typicallyDeveloping;

  String toJson() {
    switch (this) {
      case ChildGroup.asd:
        return 'asd';
      case ChildGroup.typicallyDeveloping:
        return 'typically_developing';
    }
  }

  static ChildGroup fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'asd':
      case 'autism':
        return ChildGroup.asd;
      case 'typically_developing':
      case 'td':
      case 'control':
      default:
        return ChildGroup.typicallyDeveloping;
    }
  }

  String get displayName {
    switch (this) {
      case ChildGroup.asd:
        return 'ASD';
      case ChildGroup.typicallyDeveloping:
        return 'Typically Developing';
    }
  }
}

/// ASD severity levels based on DSM-5 classification
enum AsdLevel {
  level1, // Requiring support
  level2, // Requiring substantial support
  level3; // Requiring very substantial support

  String toJson() {
    switch (this) {
      case AsdLevel.level1:
        return 'level_1';
      case AsdLevel.level2:
        return 'level_2';
      case AsdLevel.level3:
        return 'level_3';
    }
  }

  static AsdLevel fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'level_1':
      case 'level1':
      case 'mild':
        return AsdLevel.level1;
      case 'level_2':
      case 'level2':
      case 'moderate':
        return AsdLevel.level2;
      case 'level_3':
      case 'level3':
      case 'severe':
        return AsdLevel.level3;
      default:
        return AsdLevel.level1;
    }
  }

  String get displayName {
    switch (this) {
      case AsdLevel.level1:
        return 'Level 1 (Mild)';
      case AsdLevel.level2:
        return 'Level 2 (Moderate)';
      case AsdLevel.level3:
        return 'Level 3 (Severe)';
    }
  }

  String get shortName {
    switch (this) {
      case AsdLevel.level1:
        return 'Level 1';
      case AsdLevel.level2:
        return 'Level 2';
      case AsdLevel.level3:
        return 'Level 3';
    }
  }
}

/// Child profile model for clinical autism screening.
/// 
/// Captures data for children with and without a prior ASD diagnosis.
/// Used extensively throughout the app to identify patients, track their
/// demographic information, and bind them to assessment sessions.
class Child {
  /// Unique identifier (usually UUID or backend-generated ID).
  final String id;
  
  /// Human-readable study code (e.g., LRH-027, PRE-112).
  final String childCode;
  
  /// The full or abbreviated name of the child.
  final String name;
  
  /// The exact date of birth for precise age calculation.
  final DateTime dateOfBirth;
  
  /// Calculated age in full months at the time of profile creation.
  final int ageInMonths;
  
  /// String representation of gender (e.g., 'male', 'female').
  final String gender;
  
  /// Preferred language for assessment instructions.
  final String language;
  
  /// Calculated age in decimal years.
  final double age; 
  
  /// Profile creation timestamp.
  final DateTime createdAt;
  
  /// Optional hospital or clinic tracking identifier.
  final String? hospitalId;
  
  /// Distinguishes between control group and previously diagnosed group.
  final ChildGroup group;
  
  /// Specific DSM-5 level, only applicable if in the ASD group.
  final AsdLevel? asdLevel;
  
  /// The source of diagnosis or referral (e.g., Hospital clinic name).
  final String diagnosisSource;
  
  /// Unique identifier of the clinician managing this profile.
  final String? clinicianId;
  
  /// Human-readable name of the managing clinician.
  final String? clinicianName;
  
  /// Tracks if the child is a 'new' screening or 'existing' diagnosis.
  final String diagnosisType;

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
    this.clinicianId,
    this.clinicianName,
    this.diagnosisType = 'new',
  });

  /// Converts the profile to a JSON map for API payload or SQLite storage.
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
      'clinician_id': clinicianId,
      'clinician_name': clinicianName,
      'diagnosis_type': diagnosisType,
    };
  }

  /// Instantiates a [Child] from a JSON map (API response or SQLite row).
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
      group: ChildGroup.fromJson(json['group'] as String? ?? json['study_group'] as String? ?? 'typically_developing'),
      asdLevel: json['asd_level'] != null 
          ? AsdLevel.fromJson(json['asd_level'] as String)
          : null,
      diagnosisSource: json['diagnosis_source'] as String? ?? 'Unknown',
      clinicianId: json['clinician_id'] as String?,
      clinicianName: json['clinician_name'] as String?,
      diagnosisType: json['diagnosis_type'] as String? ?? 'new',
    );
  }

  /// Creates a new instance of [Child] with specific fields overridden.
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
    String? clinicianId,
    String? clinicianName,
    String? diagnosisType,
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
      clinicianId: clinicianId ?? this.clinicianId,
      clinicianName: clinicianName ?? this.clinicianName,
      diagnosisType: diagnosisType ?? this.diagnosisType,
    );
  }

  static int _calculateAgeInMonths(DateTime dob) {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months;
  }

  /// Get display string for the child's diagnosis status.
  String get groupDisplayName =>
      group == ChildGroup.asd ? 'Previously diagnosed with ASD' : 'No prior ASD diagnosis';

  /// Get display string for ASD level (if applicable).
  String? get asdLevelDisplayName => asdLevel?.displayName;

  /// Check if this child is in the ASD group.
  bool get isAsdGroup => group == ChildGroup.asd;

  /// Check if this child has no prior ASD diagnosis (screening case).
  bool get isControlGroup => group == ChildGroup.typicallyDeveloping;
}

/// Represents prior diagnosis status for a child
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
        return 'Previously diagnosed with ASD';
      case ChildGroup.typicallyDeveloping:
        return 'No prior ASD diagnosis';
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

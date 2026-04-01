/// Technology Model
/// Represents a technology entity in the application
class Technology {
  final int? id;
  final String name;
  final String description;
  final String category;
  final String? version;
  final String? documentationUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Technology({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    this.version,
    this.documentationUrl,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create Technology from JSON
  factory Technology.fromJson(Map<String, dynamic> json) {
    return Technology(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      version: json['version'] as String?,
      documentationUrl: json['documentation_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Technology to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'category': category,
      if (version != null) 'version': version,
      if (documentationUrl != null) 'documentation_url': documentationUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy of Technology with updated fields
  Technology copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? version,
    String? documentationUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Technology(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      version: version ?? this.version,
      documentationUrl: documentationUrl ?? this.documentationUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Technology(id: $id, name: $name, category: $category, version: $version, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Technology &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.category == category &&
        other.version == version &&
        other.documentationUrl == documentationUrl &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        category.hashCode ^
        version.hashCode ^
        documentationUrl.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}







/// Parent Information Model
/// 
/// Represents parent/guardian information collected during assessment setup.
class ParentInfo {
  final String name;
  final String email;
  final String phone;
  final String relationship;

  const ParentInfo({
    required this.name,
    required this.email,
    required this.phone,
    required this.relationship,
  });

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'relationship': relationship,
      };

  /// Create from JSON
  factory ParentInfo.fromJson(Map<String, dynamic> json) => ParentInfo(
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        relationship: json['relationship'] as String,
      );
}

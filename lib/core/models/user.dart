
enum UserRole {
  patient,
  doctor,
  admin,
}
class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final UserRole role;

  // Doctor specific fields
  final bool? isOnline;
  final bool isPremium;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.isOnline,
    this.isPremium = false,
  });

  // Manual serialization since we can't run build_runner easily
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.patient,
      ),
      photoUrl: json['photoUrl'] as String?,
      isOnline: json['isOnline'] as bool?,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
      'isPremium': isPremium,
    };
  }
}

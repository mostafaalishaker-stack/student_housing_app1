class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? university;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.university,
  });

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'student',
      university: json['university'],
    );
  }
}

class User {
  final String id;
  final String email;
  final String fullName;

  User({required this.id, required this.email, required this.fullName});

  // Factory untuk mengonversi JSON dari backend Golang menjadi object Dart
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}

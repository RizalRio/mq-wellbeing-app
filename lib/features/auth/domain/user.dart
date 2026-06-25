class User {
  final String id;
  final String email;
  final String fullName;
  final String role; // BARU: Menampung klaim role dari backend

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role:
          json['role'] ??
          'user', // Default ke 'user' jika kosong untuk keamanan
    );
  }
}

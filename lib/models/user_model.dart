/// Simple data object for a logged-in user.
///
/// Activity 10: the account now lives in the PostgreSQL `users` table and
/// the API returns the record as JSON, so the model reads itself from JSON.
class UserModel {
  final int? userId;
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String role;
  final String? token;

  const UserModel({
    this.userId,
    required this.username,
    required this.password,
    this.fullName = '',
    this.email = '',
    this.role = 'client',
    this.token,
  });

  bool get isValid => username.isNotEmpty && password.length >= 4;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int?,
      username: json['username'] as String? ?? '',
      password: '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

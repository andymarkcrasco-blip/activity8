/// Simple data object example.
/// In later lessons this will map to API/DB JSON.
class UserModel {
  final String username;
  final String password;

  const UserModel({required this.username, required this.password});

  bool get isValid => username.isNotEmpty && password.length >= 4;

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

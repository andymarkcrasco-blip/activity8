import '../models/user_model.dart';
import 'api_client.dart';

/// Authentication service.
///
/// Activity 8 used a local-only check. From Activity 10 the credentials are
/// verified by the FastAPI REST API against the PostgreSQL `users` table,
/// and a session token is returned on success.
class AuthService {
  final ApiClient _api;

  AuthService({ApiClient? api}) : _api = api ?? ApiClient();

  String get baseUrl => _api.baseUrl;

  /// Registers a new account. Returns the created user, or throws
  /// [ApiException] with the server's explanation.
  Future<UserModel> register({
    required String username,
    required String password,
    required String fullName,
    String? email,
    String role = 'client',
  }) async {
    final res = await _api.post('/api/auth/register', {
      'username': username,
      'password': password,
      'full_name': fullName,
      'email': (email == null || email.isEmpty) ? null : email,
      'role': role,
    });
    return UserModel.fromJson(Map<String, dynamic>.from(res['user'] as Map));
  }

  /// Logs in against the API. Returns null on success, or an error message.
  Future<String?> login(UserModel user) async {
    try {
      final res = await _api.post('/api/auth/login', {
        'username': user.username,
        'password': user.password,
      });
      if (res is Map && res['ok'] == true) {
        return null;
      }
      return 'Login was refused by the server.';
    } on ApiException catch (e) {
      return e.message;
    }
  }

  /// Checks that the API and the database are reachable.
  Future<bool> isBackendOnline() async {
    try {
      final res = await _api.get('/api/health');
      if (res is Map && res['database'] == 'connected') return true;
      return false;
    } catch (_) {
      return false;
    }
  }
}

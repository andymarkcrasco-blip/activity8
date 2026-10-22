import '../models/user_model.dart';
// ignore: unused_import - http is added intentionally for Lesson 8 package demo.
// In future lessons this service will call a real REST API.
import 'package:http/http.dart' as http;

/// Local-only auth for initialization stage.
/// API connection comes later, but the UI flow already works.
class AuthService {
  // Demo user for classroom checking (local only, no backend yet).
  static const demoUser = UserModel(username: 'student', password: '1234');

  /// Returns null on success, or an error message string.
  Future<String?> login(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (user.username.isEmpty || user.password.isEmpty) {
      return 'Please enter username and password.';
    }
    if (user.password.length < 4) {
      return 'Password must be at least 4 characters.';
    }
    // Local check only for Activity 8.
    // Example future API call:
    // final res = await http.post(Uri.parse('https://example.com/api/login'),
    //     body: user.toJson());
    // ignore: avoid_print
    print('http package ready: ${http.Client}');
    return null; // success
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Login page / placeholder with local validation.
/// Flow: input -> validation -> message / next page.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  String _message = 'Demo login: student / 1234 (local only, no API yet)';
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = 'Checking...';
    });
    final err = await _auth.login(
      UserModel(username: _userCtrl.text.trim(), password: _passCtrl.text),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _message = err ?? 'Login success! Opening dashboard...';
    });
    if (err == null) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) context.go(AppConstants.dashboardRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Login', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Username',
              controller: _userCtrl,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Password',
              controller: _passCtrl,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 4) return 'Min 4 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : AppButton(label: 'Login', icon: Icons.login, onPressed: _onLogin),
            const SizedBox(height: 12),
            Text(_message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

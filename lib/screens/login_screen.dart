import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Login page for the EventVenue Caraga system.
///
/// Activity 10: the credentials are now checked by the FastAPI REST API
/// against the PostgreSQL `users` table instead of a local placeholder.
/// The flow is still the same as Activity 9: input -> validation ->
/// message / next page.
class LoginScreen extends StatefulWidget {
  /// Optional service override, used by the automated tests.
  final AuthService? service;

  const LoginScreen({super.key, this.service});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  /// Created from the widget so tests can inject a mocked service.
  late final AuthService _auth = widget.service ?? AuthService();
  String _message = 'Accounts are stored in PostgreSQL. Register one from the REST API.';
  bool _loading = false;
  bool _backendOnline = false;

  @override
  void initState() {
    super.initState();
    _checkBackend();
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkBackend() async {
    final online = await _auth.isBackendOnline();
    if (!mounted) return;
    setState(() => _backendOnline = online);
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = 'Checking your account...';
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
            const SizedBox(height: 4),
            Center(
              child: Text(
                _backendOnline
                    ? 'REST API connected - PostgreSQL online'
                    : 'REST API offline - start backend/main.py',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _backendOnline ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
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

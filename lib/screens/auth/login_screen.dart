import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../core/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  final _api = ApiClient();
  final _storage = StorageService();

  @override
  void dispose() {
    _userNameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final response = await _api.login({
        'userName': _userNameCtrl.text.trim(),
        'password': _passwordCtrl.text,
      });

      final token = response?['token'] ??
          response?['Token'] ??
          (response is String ? response : null);

      if (token == null) {
        throw ApiException('Login succeeded but no token was returned.');
      }

      await context.read<AuthProvider>().setSession(
        token as String,
        {'userName': _userNameCtrl.text.trim()},
      );

      if (mounted) context.go('/overview');
    } catch (e) {
      await _storage.clearSession();
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero gradient header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 52, 28, 40),
                decoration: BoxDecoration(gradient: colors.gradient),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'FT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Finance Tracker',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to your account',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      StatusBanner(tone: 'error', message: _errorMessage),
                      if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                      AppTextField(
                        label: 'Username',
                        controller: _userNameCtrl,
                        placeholder: 'your_username',
                        keyboardType: TextInputType.text,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Username is required' : null,
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Password',
                        controller: _passwordCtrl,
                        placeholder: 'Enter your password',
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colors.muted,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Password is required' : null,
                      ),
                      const SizedBox(height: 28),

                      PrimaryButton(
                        label: _isSubmitting ? 'Signing in...' : 'Login',
                        onPressed: _isSubmitting ? null : _handleLogin,
                        isLoading: _isSubmitting,
                        icon: Icons.login_rounded,
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style:
                                  TextStyle(color: colors.muted, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/auth/signup'),
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: colors.brand,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

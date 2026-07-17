import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String _errorMessage = '';
  String _successMessage = '';

  final _api = ApiClient();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      await _api.signup({
        'name': _nameCtrl.text.trim(),
        'userName': _userNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
      });

      _nameCtrl.clear();
      _userNameCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
      setState(() => _successMessage = 'Account created! You can login now.');
    } catch (e) {
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
              // Gradient header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 52, 28, 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF064E3B),
                      const Color(0xFF059669),
                      const Color(0xFF10B981),
                    ],
                  ),
                ),
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
                      'SIGNUP',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Create account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
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
                      StatusBanner(tone: 'success', message: _successMessage),
                      if (_errorMessage.isNotEmpty || _successMessage.isNotEmpty)
                        const SizedBox(height: 16),

                      AppTextField(
                        label: 'Name',
                        controller: _nameCtrl,
                        placeholder: 'Your name',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Username',
                        controller: _userNameCtrl,
                        placeholder: 'your_username',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Username is required' : null,
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Email',
                        controller: _emailCtrl,
                        placeholder: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Password',
                        controller: _passwordCtrl,
                        placeholder: 'Create a password',
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
                        label: _isSubmitting ? 'Creating account...' : 'Sign Up',
                        onPressed: _isSubmitting ? null : _handleSignup,
                        isLoading: _isSubmitting,
                        icon: Icons.person_add_rounded,
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already registered? ',
                              style:
                                  TextStyle(color: colors.muted, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/auth/login'),
                              child: Text(
                                'Login here',
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

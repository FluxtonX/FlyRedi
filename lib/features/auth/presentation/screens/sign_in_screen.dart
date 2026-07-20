import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/app_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/google_sign_in_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  // Independent loading states for each button
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  bool _validateInputs() {
    String? emailErr;
    String? passErr;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      emailErr = 'Email is required.';
    } else if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email)) {
      emailErr = 'Enter a valid email address.';
    }

    if (password.isEmpty) {
      passErr = 'Password is required.';
    } else if (password.length < 6) {
      passErr = 'Password must be at least 6 characters.';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;
    if (_isEmailLoading || _isGoogleLoading) return;
    FocusScope.of(context).unfocus();

    setState(() => _isEmailLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isEmailLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } else {
      _showError(auth);
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_isEmailLoading || _isGoogleLoading) return;
    FocusScope.of(context).unfocus();

    setState(() => _isGoogleLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithGoogle();

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } else {
      _showError(auth);
    }
  }

  void _showError(AuthProvider auth) {
    final error = auth.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
      auth.clearError();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anyLoading = _isEmailLoading || _isGoogleLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Image.asset(
                    'assets/images/flyredilogo.png',
                    height: 120,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to your FlyRedi account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                AuthTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  enableSuggestions: true,
                ),
                if (_emailError != null) ...[
                  const SizedBox(height: 6),
                  _buildFieldError(_emailError!),
                ],
                const SizedBox(height: 20),

                // Password field
                AuthTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  autocorrect: false,
                  enableSuggestions: false,
                  onSubmitted: (_) => _handleLogin(),
                ),
                if (_passwordError != null) ...[
                  const SizedBox(height: 6),
                  _buildFieldError(_passwordError!),
                ],
                const SizedBox(height: 16),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRouter.forgotPassword),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFFFFC229),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign In button
                CustomButton(
                  title: 'Sign In',
                  onTap: anyLoading ? () {} : _handleLogin,
                  isLoading: _isEmailLoading,
                ),
                const SizedBox(height: 24),

                // OR divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFF3A3A4E), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFF3A3A4E), thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign-In
                GoogleSignInButton(
                  onTap: anyLoading ? () {} : _handleGoogleLogin,
                  isLoading: _isGoogleLoading,
                ),
                const SizedBox(height: 30),

                // Sign Up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRouter.register),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFFFFC229),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldError(String message) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFE11D48)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFE11D48),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

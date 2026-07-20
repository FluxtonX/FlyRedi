import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/app_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/google_sign_in_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  // Independent loading states for each button
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  bool _validateInputs() {
    String? nameErr;
    String? emailErr;
    String? passErr;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty) {
      nameErr = 'Full name is required.';
    } else if (name.length < 2) {
      nameErr = 'Name must be at least 2 characters.';
    }

    if (email.isEmpty) {
      emailErr = 'Email is required.';
    } else if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email)) {
      emailErr = 'Enter a valid email address.';
    }

    if (password.isEmpty) {
      passErr = 'Password is required.';
    } else if (password.length < 8) {
      passErr = 'Password must be at least 8 characters.';
    } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(password)) {
      passErr = 'Password must include letters and numbers.';
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return nameErr == null && emailErr == null && passErr == null;
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_validateInputs()) return;
    if (_isEmailLoading || _isGoogleLoading) return;

    setState(() => _isEmailLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
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
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    nameController.dispose();
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              0,
              24,
              MediaQuery.viewInsetsOf(context).bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/images/flyredilogo.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get started with FlyRedi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 35),

                // Full Name field
                AuthTextField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => emailFocusNode.requestFocus(),
                ),
                if (_nameError != null) ...[
                  const SizedBox(height: 6),
                  _buildFieldError(_nameError!),
                ],
                const SizedBox(height: 18),

                // Email field
                AuthTextField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  enableSuggestions: true,
                  onSubmitted: (_) => passwordFocusNode.requestFocus(),
                ),
                if (_emailError != null) ...[
                  const SizedBox(height: 6),
                  _buildFieldError(_emailError!),
                ],
                const SizedBox(height: 18),

                // Password field
                AuthTextField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  label: 'Password',
                  hint: 'Create your password (min. 8 characters)',
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  autocorrect: false,
                  enableSuggestions: false,
                  onSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'Use at least 8 characters with letters and numbers.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_passwordError != null) ...[
                  const SizedBox(height: 6),
                  _buildFieldError(_passwordError!),
                ],
                const SizedBox(height: 28),

                // Create Account button
                CustomButton(
                  title: 'Create Account',
                  onTap: anyLoading ? () {} : _handleRegister,
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
                const SizedBox(height: 24),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, AppRouter.login),
                      child: const Text(
                        'Sign In',
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

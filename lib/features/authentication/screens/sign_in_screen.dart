import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reset_password_screen.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/auth_textfield.dart';
import 'sign_up_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../traveller/screens/traveller_tabs_screen.dart';
import '../../../shared/services/api_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // ─── Validation ────────────────────────────────────────────────────────────

  String? _emailError;
  String? _passwordError;

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

  // ─── Show styled SnackBar ───────────────────────────────────────────────────

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE11D48) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── Login Logic ────────────────────────────────────────────────────────────

  Future<void> loginUser() async {
    if (!_validateInputs()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Sync user with backend and get profile
      final syncResponse = await ApiService.post('/api/auth/sync');

      if (!mounted) return;

      // Determine routing based on onboardingCompleted flag
      bool onboardingCompleted = false;
      if (syncResponse.statusCode == 200) {
        try {
          final data = jsonDecode(syncResponse.body);
          onboardingCompleted = data['onboardingCompleted'] == true;
        } catch (_) {}
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => onboardingCompleted
              ? const TravellerTabsScreen()
              : const OnboardingScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showSnackBar(_mapFirebaseError(e.code));
    } catch (_) {
      _showSnackBar('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ─── Firebase error → readable message ─────────────────────────────────────

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'user-disabled':
        return 'Your account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071B3A),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordScreen(),
                        ),
                      );
                    },
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
                  title: isLoading ? 'Signing In...' : 'Sign In',
                  onTap: isLoading ? () {} : loginUser,
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
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
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFE11D48),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

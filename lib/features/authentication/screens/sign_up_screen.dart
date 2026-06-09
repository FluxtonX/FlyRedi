import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/auth_textfield.dart';
import 'sign_in_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../../shared/services/api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  // ─── Validation ─────────────────────────────────────────────────────────────

  bool _validateInputs() {
    String? nameErr;
    String? emailErr;
    String? passErr;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

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
    } else if (password.length < 6) {
      passErr = 'Password must be at least 6 characters.';
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return nameErr == null && emailErr == null && passErr == null;
  }

  // ─── Snack Bar ────────────────────────────────────────────────────────────

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

  // ─── Sign Up Logic ─────────────────────────────────────────────────────────

  Future<void> signUpUser() async {
    if (!_validateInputs()) return;

    setState(() => isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Set displayName immediately after sign-up
      await userCredential.user?.updateDisplayName(nameController.text.trim());

      // Sync new user to backend (creates Firestore profile)
      final syncResponse = await ApiService.post('/api/auth/sync');

      if (!mounted) return;

      // For new users, onboarding is always not completed
      bool onboardingCompleted = false;
      if (syncResponse.statusCode == 200) {
        try {
          final data = jsonDecode(syncResponse.body);
          onboardingCompleted = data['onboardingCompleted'] == true;
        } catch (_) {}
      }

      _showSnackBar('Account created successfully!', isError: false);

      // Small delay so user sees the success toast before navigation
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => onboardingCompleted
              ? const SignInScreen()
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

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Sign up failed. Please try again.';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

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
                  'Get started with SkyRightz360',
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
                  label: 'Full Name',
                  hint: 'Enter your full name',
                ),
                if (_nameError != null) ...[
                  const SizedBox(height: 6),
                  _buildFieldError(_nameError!),
                ],
                const SizedBox(height: 18),

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
                const SizedBox(height: 18),

                // Password field
                AuthTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Create your password (min. 6 characters)',
                  obscureText: true,
                ),
                if (_passwordError != null) ...[
                  const SizedBox(height: 6),
                  _buildFieldError(_passwordError!),
                ],
                const SizedBox(height: 28),

                // Create Account button
                CustomButton(
                  title: isLoading ? 'Creating Account...' : 'Create Account',
                  onTap: isLoading ? () {} : signUpUser,
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                        );
                      },
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

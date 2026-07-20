import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  String? _emailError;

  bool _validateInputs() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required.');
      return false;
    } else if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email address.');
      return false;
    }
    setState(() => _emailError = null);
    return true;
  }

  Future<void> _handleSendResetLink() async {
    if (!_validateInputs()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPassword(emailController.text.trim());

    if (!mounted) return;

    if (success) {
      emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent! Check your email.'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } else {
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
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>((p) => p.isLoading);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white70),
                    SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                'Reset password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your email to receive a reset link',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 40),
              AuthTextField(
                controller: emailController,
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSendResetLink(),
              ),
              if (_emailError != null) ...[
                const SizedBox(height: 6),
                _buildFieldError(_emailError!),
              ],
              const SizedBox(height: 40),
              CustomButton(
                title: isLoading ? 'Sending Link...' : 'Send Reset Link',
                onTap: isLoading ? () {} : _handleSendResetLink,
              ),
            ],
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

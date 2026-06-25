import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_textfield.dart';
import '../../../../core/widgets/custom_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();

  final RxnString _emailError = RxnString();

  bool _validateInputs() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _emailError.value = 'Email is required.';
      return false;
    } else if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email)) {
      _emailError.value = 'Enter a valid email address.';
      return false;
    }
    _emailError.value = null;
    return true;
  }

  Future<void> _handleSendResetLink() async {
    if (!_validateInputs()) return;
    FocusScope.of(context).unfocus();
    
    final success = await _authController.forgotPassword(emailController.text.trim());
    if (success) {
      emailController.clear();
      await Future.delayed(const Duration(seconds: 2));
      Get.back();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 60),
              const Text(
                'Reset password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              const Text(
                'Enter your email to receive a reset link',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 40),
              AuthTextField(
                controller: emailController,
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSendResetLink(),
              ),
              Obx(() => _emailError.value != null
                  ? Column(
                      children: [
                        SizedBox(height: 6),
                        _buildFieldError(_emailError.value!),
                      ],
                    )
                  : SizedBox.shrink()),
              SizedBox(height: 40),
              Obx(() => CustomButton(
                    title: _authController.isLoading.value ? 'Sending Link...' : 'Send Reset Link',
                    onTap: _authController.isLoading.value ? () {} : _handleSendResetLink,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldError(String message) {
    return Padding(
      padding: EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFE11D48)),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
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

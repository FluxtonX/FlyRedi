import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_textfield.dart';
import '../../../../core/widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  final RxnString _nameError = RxnString();
  final RxnString _emailError = RxnString();
  final RxnString _passwordError = RxnString();

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

    _nameError.value = nameErr;
    _emailError.value = emailErr;
    _passwordError.value = passErr;

    return nameErr == null && emailErr == null && passErr == null;
  }

  Future<void> _handleRegister() async {
    if (_authController.isLoading.value) return;
    FocusScope.of(context).unfocus();
    if (!_validateInputs()) return;

    await _authController.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFF071B3A),
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
                Obx(() => _nameError.value != null
                    ? Column(
                        children: [
                          const SizedBox(height: 6),
                          _buildFieldError(_nameError.value!),
                        ],
                      )
                    : const SizedBox.shrink()),
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
                Obx(() => _emailError.value != null
                    ? Column(
                        children: [
                          const SizedBox(height: 6),
                          _buildFieldError(_emailError.value!),
                        ],
                      )
                    : const SizedBox.shrink()),
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
                Obx(() => _passwordError.value != null
                    ? Column(
                        children: [
                          const SizedBox(height: 6),
                          _buildFieldError(_passwordError.value!),
                        ],
                      )
                    : const SizedBox.shrink()),
                const SizedBox(height: 28),

                // Create Account button
                Obx(() => CustomButton(
                      title: 'Create Account',
                      onTap: _authController.isLoading.value ? () {} : _handleRegister,
                      isLoading: _authController.isLoading.value,
                    )),
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
                      onTap: () => Get.toNamed('/login'),
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
          const Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: Color(0xFFE11D48),
          ),
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

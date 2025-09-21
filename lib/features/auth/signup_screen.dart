import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/services/user_service.dart';
import '../../core/utils/validators.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userService = ref.read(userServiceProvider);

      // Sign up the user
      final response = await userService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {

        if (response.session != null) {
          // User created successfully with session, go to profile setup
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.of(context).pushReplacementNamed('/profile-setup');
        } else {
          // User created but needs email confirmation
          if (mounted) {
            _showErrorSnackBar('Please check your email and click the confirmation link before proceeding. Then try logging in.');
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Signup failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Encomunita'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.neutralDark,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryCoral.withOpacity(0.05),
              AppColors.primaryTeal.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Welcome Header
                  _buildWelcomeHeader(),

                  const SizedBox(height: 48),

                  // Email Field
                  _buildEmailField(),

                  const SizedBox(height: 20),

                  // Password Field
                  _buildPasswordField(),

                  const SizedBox(height: 20),

                  // Confirm Password Field
                  _buildConfirmPasswordField(),

                  const SizedBox(height: 12),

                  // Terms and Privacy Notice
                  _buildTermsNotice(),

                  const SizedBox(height: 32),

                  // Signup Button
                  _buildSignupButton(),

                  const SizedBox(height: 24),

                  // Already have account
                  _buildLoginPrompt(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        AppIcons.iconWithBackground(
          icon: AppIcons.signup,
          backgroundColor: AppColors.primaryTeal,
          size: 32,
          containerSize: 80,
        ),
        const SizedBox(height: 24),
        Text(
          'Join Your Community',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Create your Encomunita account and start connecting with neighbors',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.neutralMedium,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email',
        prefixIcon: const Icon(AppIcons.email),
      ),
      validator: Validators.validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Create a strong password',
        prefixIcon: const Icon(AppIcons.password),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? AppIcons.visibilityOff : AppIcons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: Validators.validatePassword,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSignup(),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        prefixIcon: const Icon(AppIcons.password),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? AppIcons.visibilityOff : AppIcons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
    );
  }

  Widget _buildTermsNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'By signing up, you agree to our Terms of Service and Privacy Policy. Your data is protected and secure.',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.neutralMedium,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignup,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.neutralWhite),
                ),
              )
            : const Text('Create Account'),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            color: AppColors.neutralMedium,
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
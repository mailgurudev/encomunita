import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/services/user_service.dart';
import '../../core/utils/validators.dart';
import '../profile_setup/profile_setup_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userService = ref.read(userServiceProvider);

      // Sign in the user
      final response = await userService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        // Check if user has a profile
        final profile = await userService.getCurrentProfile();

        if (profile != null) {
          // User has profile, go to home
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // User needs to set up profile
          // Add a small delay to ensure session is fully established
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.of(context).pushReplacementNamed('/profile-setup');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Login failed: ${e.toString()}');
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
        title: const Text('Welcome Back'),
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

                  // Welcome Back Message
                  _buildWelcomeHeader(),

                  const SizedBox(height: 48),

                  // Email Field
                  _buildEmailField(),

                  const SizedBox(height: 20),

                  // Password Field
                  _buildPasswordField(),

                  const SizedBox(height: 12),

                  // Forgot Password Link
                  _buildForgotPasswordLink(),

                  const SizedBox(height: 32),

                  // Login Button
                  _buildLoginButton(),

                  const SizedBox(height: 24),

                  // Don't have account
                  _buildSignupPrompt(),

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
          icon: AppIcons.login,
          backgroundColor: AppColors.primaryCoral,
          size: 32,
          containerSize: 80,
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your Encomunita account',
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
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password
          _showErrorSnackBar('Forgot password feature coming soon!');
        },
        child: const Text('Forgot Password?'),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.neutralWhite),
                ),
              )
            : const Text('Sign In'),
      ),
    );
  }

  Widget _buildSignupPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: AppColors.neutralMedium,
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/signup');
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text(
            'Sign Up',
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
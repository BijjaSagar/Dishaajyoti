import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/inputs/custom_text_field.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../utils/validators.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'dashboard_screen.dart';

/// Login screen with email and password authentication
/// Supports social login (Google, Apple) and password reset
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleLogin() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate form
    final emailValidation = Validators.email(_emailController.text);
    final passwordValidation = Validators.password(_passwordController.text);

    if (emailValidation != null || passwordValidation != null) {
      setState(() {
        _emailError = emailValidation;
        _passwordError = passwordValidation;
      });
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual login logic with AuthService
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Stop loading state first
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Small delay to ensure state update completes
      await Future.delayed(const Duration(milliseconds: 50));

      // Navigate to dashboard on success
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    // TODO: Implement Google Sign-In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  Future<void> _handleAppleLogin() async {
    // TODO: Implement Apple Sign-In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign-In coming soon'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  void _navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Welcome Back',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your journey',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  errorText: _emailError,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryBlue,
                  ),
                  onChanged: (value) {
                    if (_emailError != null) {
                      setState(() {
                        _emailError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  errorText: _passwordError,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primaryBlue,
                  ),
                  suffixIcon: Semantics(
                    button: true,
                    label:
                        _isPasswordVisible ? 'Hide password' : 'Show password',
                    hint: 'Double tap to toggle password visibility',
                    child: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.primaryBlue,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  onChanged: (value) {
                    if (_passwordError != null) {
                      setState(() {
                        _passwordError = null;
                      });
                    }
                  },
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 12),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
                    button: true,
                    label: 'Forgot Password',
                    hint: 'Double tap to reset your password',
                    child: TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                PrimaryButton(
                  label: 'Login',
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 32),

                // Divider with "OR"
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: AppColors.mediumGray,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: AppColors.mediumGray,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Social login buttons
                SecondaryButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata,
                  onPressed: _handleGoogleLogin,
                ),
                const SizedBox(height: 16),
                SecondaryButton(
                  label: 'Continue with Apple',
                  icon: Icons.apple,
                  onPressed: _handleAppleLogin,
                ),
                const SizedBox(height: 32),

                // Sign up link
                Semantics(
                  button: true,
                  label: "Don't have an account? Sign Up",
                  hint: 'Double tap to create a new account',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToSignup,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        child: Text(
                          'Sign Up',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

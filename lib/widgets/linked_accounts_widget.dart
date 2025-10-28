import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Widget to display and manage linked authentication providers
/// Shows which providers (Email, Google, Apple, Phone) are linked to the account
class LinkedAccountsWidget extends StatefulWidget {
  const LinkedAccountsWidget({super.key});

  @override
  State<LinkedAccountsWidget> createState() => _LinkedAccountsWidgetState();
}

class _LinkedAccountsWidgetState extends State<LinkedAccountsWidget> {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;
  List<String> _linkedProviders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLinkedProviders();
  }

  void _loadLinkedProviders() {
    setState(() {
      _linkedProviders = _authService.getLinkedProviders();
    });
  }

  bool _isProviderLinked(String providerId) {
    return _linkedProviders.contains(providerId);
  }

  Future<void> _linkGoogleAccount() async {
    setState(() => _isLoading = true);

    try {
      await _authService.linkWithGoogle();
      _loadLinkedProviders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google account linked successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Failed to link Google account';
        if (e.code == 'provider-already-linked') {
          message = 'This Google account is already linked';
        } else if (e.code == 'credential-already-in-use') {
          message = 'This Google account is already used by another user';
        } else if (e.code == 'ERROR_ABORTED_BY_USER') {
          message = 'Sign-in cancelled';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _linkAppleAccount() async {
    setState(() => _isLoading = true);

    try {
      await _authService.linkWithApple();
      _loadLinkedProviders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple account linked successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Failed to link Apple account';
        if (e.code == 'provider-already-linked') {
          message = 'This Apple account is already linked';
        } else if (e.code == 'credential-already-in-use') {
          message = 'This Apple account is already used by another user';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getProviderDisplayName(String providerId) {
    switch (providerId) {
      case 'password':
        return 'Email & Password';
      case 'google.com':
        return 'Google';
      case 'apple.com':
        return 'Apple';
      case 'phone':
        return 'Phone Number';
      default:
        return providerId;
    }
  }

  IconData _getProviderIcon(String providerId) {
    switch (providerId) {
      case 'password':
        return Icons.email;
      case 'google.com':
        return Icons.g_mobiledata;
      case 'apple.com':
        return Icons.apple;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.account_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Linked Accounts',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Link multiple sign-in methods to your account for easier access',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Display linked providers
            if (_linkedProviders.isNotEmpty) ...[
              Text(
                'Connected Methods',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._linkedProviders.map((providerId) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          _getProviderIcon(providerId),
                          color: AppColors.primaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getProviderDisplayName(providerId),
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Link Google account
            if (!_isProviderLinked('google.com')) ...[
              Text(
                'Available Methods',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _LinkAccountButton(
                icon: Icons.g_mobiledata,
                label: 'Link Google Account',
                onPressed: _isLoading ? null : _linkGoogleAccount,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 8),
            ],

            // Link Apple account (iOS only)
            if (!_isProviderLinked('apple.com') &&
                Theme.of(context).platform == TargetPlatform.iOS) ...[
              _LinkAccountButton(
                icon: Icons.apple,
                label: 'Link Apple Account',
                onPressed: _isLoading ? null : _linkAppleAccount,
                isLoading: _isLoading,
              ),
            ],

            // Info message if all providers are linked
            if (_isProviderLinked('google.com') &&
                (_isProviderLinked('apple.com') ||
                    Theme.of(context).platform != TargetPlatform.iOS)) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All available sign-in methods are linked',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinkAccountButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _LinkAccountButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            )
          else
            Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

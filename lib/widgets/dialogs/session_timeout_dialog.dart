import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// Session timeout warning dialog
///
/// Requirements: 11.2, 11.3
class SessionTimeoutDialog extends StatelessWidget {
  final int remainingMinutes;
  final VoidCallback onContinue;
  final VoidCallback onLogout;

  const SessionTimeoutDialog({
    super.key,
    required this.remainingMinutes,
    required this.onContinue,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time,
                size: 32,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Session Expiring Soon',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              'Your session will expire in $remainingMinutes ${remainingMinutes == 1 ? 'minute' : 'minutes'} due to inactivity. Would you like to continue?',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Logout',
                    onPressed: onLogout,
                    height: 48,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Continue',
                    onPressed: onContinue,
                    height: 48,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show session timeout dialog
  static Future<bool?> show(
    BuildContext context, {
    required int remainingMinutes,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionTimeoutDialog(
        remainingMinutes: remainingMinutes,
        onContinue: () => Navigator.of(context).pop(true),
        onLogout: () => Navigator.of(context).pop(false),
      ),
    );
  }
}

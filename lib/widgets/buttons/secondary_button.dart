import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Secondary button with blue border and transparent background
/// Used for secondary actions throughout the app
class SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.forward();
  }

  void _onTapCancel() {
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    // Create semantic label for screen readers
    final semanticLabel = widget.isLoading
        ? 'Loading, ${widget.label}'
        : isDisabled
            ? '${widget.label}, disabled'
            : widget.label;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: semanticLabel,
      hint: isDisabled
          ? 'Button is currently disabled'
          : 'Double tap to activate',
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: isDisabled ? AppColors.mediumGray : AppColors.primaryBlue,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : widget.onPressed,
              onTapDown: isDisabled ? null : _onTapDown,
              onTapUp: isDisabled ? null : _onTapUp,
              onTapCancel: isDisabled ? null : _onTapCancel,
              borderRadius: BorderRadius.circular(12),
              splashColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              highlightColor: AppColors.primaryBlue.withValues(alpha: 0.05),
              child: Center(
                child: widget.isLoading
                    ? Semantics(
                        label: 'Loading',
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDisabled
                                  ? AppColors.mediumGray
                                  : AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: isDisabled
                                  ? AppColors.mediumGray
                                  : AppColors.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: AppTypography.button.copyWith(
                              color: isDisabled
                                  ? AppColors.mediumGray
                                  : AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

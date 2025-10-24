import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../buttons/primary_button.dart';

/// Service card widget displaying service information with icon, name, and price
/// Used in the dashboard and services screen
class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Optimized: Cache text styles to prevent rebuilds
    final priceStyle = AppTypography.h3.copyWith(
      color: AppColors.darkOrange,
      fontWeight: FontWeight.bold,
    );
    final nameStyle = AppTypography.h3.copyWith(
      color: AppColors.darkBlue,
    );

    // Create semantic label for screen readers
    final semanticLabel =
        '${service.name}, Price: ${service.price} rupees, ${service.description}';

    return Semantics(
      label: semanticLabel,
      button: true,
      hint: 'Double tap to select this service',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Semantics(
                  label: '${service.name} icon',
                  child: Text(
                    service.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                Semantics(
                  label: 'Price: ${service.price} rupees',
                  child: Text(
                    '₹${service.price}',
                    style: priceStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              service.name,
              style: nameStyle,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Get Now',
              height: 44,
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

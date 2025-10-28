import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../buttons/primary_button.dart';

/// Service card widget displaying service information with icon, name, description, features, and price
/// Used in the dashboard and services screen
class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;
  final bool showFullDetails;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.showFullDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    // Create semantic label for screen readers
    final semanticLabel =
        '${service.name}, Price: ${service.price == 0 ? 'Free' : '${service.price} rupees'}, ${service.description}';

    return Semantics(
      label: semanticLabel,
      button: true,
      hint: 'Double tap to select this service',
      child: Container(
        padding: const EdgeInsets.all(20),
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
            // Header with icon and price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Semantics(
                    label: '${service.name} icon',
                    child: Text(
                      service.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: service.isFree
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Semantics(
                    label: service.isFree
                        ? 'Free service'
                        : 'Price: ${service.price} rupees',
                    child: Text(
                      service.isFree ? 'FREE' : '₹${service.price}',
                      style: AppTypography.bodyLarge.copyWith(
                        color: service.isFree
                            ? AppColors.success
                            : AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Service name
            Text(
              service.name,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Service description
            Text(
              service.description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (showFullDetails) ...[
              const SizedBox(height: 16),

              // Features list
              ...service.features.take(3).map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 16),

              // Estimated time
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Delivery: ${service.estimatedTime}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: service.isFree ? 'Get Started' : 'Order Now',
                height: 48,
                onPressed: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

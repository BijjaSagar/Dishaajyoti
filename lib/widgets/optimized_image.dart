import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

/// Optimized image widget with caching and loading states
///
/// Uses cached_network_image for efficient image loading and caching
/// Requirements: 1.3
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildDefaultErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      // Memory cache configuration
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      // Max cache size: 100 images
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.lightGray,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.lightGray,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.textSecondary,
          size: 32,
        ),
      ),
    );
  }
}

/// Optimized circular avatar with cached network image
class OptimizedAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 40,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lightGray,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              placeholder ?? _buildDefaultPlaceholder(),
          errorWidget: (context, url, error) =>
              errorWidget ?? _buildDefaultErrorWidget(),
          fadeInDuration: const Duration(milliseconds: 300),
          memCacheWidth: (radius * 2).toInt(),
          memCacheHeight: (radius * 2).toInt(),
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return const Center(
      child: Icon(
        Icons.person_outline,
        color: AppColors.textSecondary,
        size: 32,
      ),
    );
  }
}

/// Optimized thumbnail image for lists
class OptimizedThumbnail extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const OptimizedThumbnail({
    super.key,
    required this.imageUrl,
    this.size = 60,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      placeholder: _buildPlaceholder(),
      errorWidget: _buildErrorWidget(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}

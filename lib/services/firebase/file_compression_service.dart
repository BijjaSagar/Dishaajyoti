import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for compressing files before upload to Cloud Storage
/// Handles image compression and conversion to WebP format
class FileCompressionService {
  // Singleton instance
  static final FileCompressionService _instance =
      FileCompressionService._internal();

  factory FileCompressionService() => _instance;

  FileCompressionService._internal();

  // Convenience getter for singleton instance
  static FileCompressionService get instance => _instance;

  // Compression settings
  static const int _targetImageSizeKB = 500; // Target size: 500KB
  static const int _maxImageSizeKB = 500; // Maximum size: 500KB
  static const int _defaultQuality = 85; // Default compression quality
  static const int _minQuality =
      50; // Minimum quality for aggressive compression

  // ==================== Image Compression ====================

  /// Compress image file to target size
  /// Returns compressed file or original if compression fails
  Future<File> compressImage({
    required File imageFile,
    int targetSizeKB = _targetImageSizeKB,
    int quality = _defaultQuality,
    bool convertToWebP = true,
  }) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Check current file size
      final fileSize = await imageFile.length();
      final fileSizeKB = fileSize ~/ 1024;

      debugPrint('Original image size: $fileSizeKB KB');

      // If file is already smaller than target, return original
      if (fileSizeKB <= targetSizeKB) {
        debugPrint('Image already within target size, no compression needed');
        return imageFile;
      }

      // Get temp directory for compressed file
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final extension = convertToWebP ? 'webp' : path.extension(imageFile.path);
      final compressedPath = path.join(
        tempDir.path,
        '${fileName}_compressed$extension',
      );

      // Compress image
      File? compressedFile = await _compressImageWithQuality(
        imageFile: imageFile,
        targetPath: compressedPath,
        quality: quality,
        format: convertToWebP ? CompressFormat.webp : CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        debugPrint('Compression failed, returning original file');
        return imageFile;
      }

      // Check compressed file size
      final compressedSize = await compressedFile.length();
      final compressedSizeKB = compressedSize ~/ 1024;

      debugPrint('Compressed image size: $compressedSizeKB KB');

      // If still too large, try more aggressive compression
      if (compressedSizeKB > targetSizeKB && quality > _minQuality) {
        debugPrint('File still too large, trying more aggressive compression');

        final aggressiveQuality = (quality * 0.7).round();
        compressedFile = await _compressImageWithQuality(
          imageFile: imageFile,
          targetPath: compressedPath,
          quality: aggressiveQuality,
          format: convertToWebP ? CompressFormat.webp : CompressFormat.jpeg,
        );

        if (compressedFile != null) {
          final finalSize = await compressedFile.length();
          final finalSizeKB = finalSize ~/ 1024;
          debugPrint('Final compressed size: $finalSizeKB KB');
        }
      }

      return compressedFile ?? imageFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      // Return original file if compression fails
      return imageFile;
    }
  }

  /// Compress image with specific quality
  Future<File?> _compressImageWithQuality({
    required File imageFile,
    required String targetPath,
    required int quality,
    required CompressFormat format,
  }) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        format: format,
        minWidth: 1920,
        minHeight: 1920,
        keepExif: false,
      );

      if (result == null) {
        return null;
      }

      return File(result.path);
    } catch (e) {
      debugPrint('Error in compression: $e');
      return null;
    }
  }

  /// Compress image to WebP format
  /// WebP provides better compression than JPEG/PNG
  Future<File> compressToWebP({
    required File imageFile,
    int quality = _defaultQuality,
  }) async {
    return compressImage(
      imageFile: imageFile,
      quality: quality,
      convertToWebP: true,
    );
  }

  /// Compress image for thumbnail (smaller size)
  Future<File> compressThumbnail({
    required File imageFile,
    int maxWidth = 300,
    int maxHeight = 300,
    int quality = 80,
  }) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final thumbnailPath = path.join(
        tempDir.path,
        '${fileName}_thumb.webp',
      );

      // Compress to thumbnail size
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        thumbnailPath,
        quality: quality,
        format: CompressFormat.webp,
        minWidth: maxWidth,
        minHeight: maxHeight,
        keepExif: false,
      );

      if (result == null) {
        debugPrint('Thumbnail compression failed, returning original');
        return imageFile;
      }

      final thumbnailFile = File(result.path);
      final thumbnailSize = await thumbnailFile.length();
      debugPrint('Thumbnail size: ${thumbnailSize ~/ 1024} KB');

      return thumbnailFile;
    } catch (e) {
      debugPrint('Error compressing thumbnail: $e');
      return imageFile;
    }
  }

  /// Compress multiple images in batch
  Future<List<File>> compressImages({
    required List<File> imageFiles,
    int targetSizeKB = _targetImageSizeKB,
    int quality = _defaultQuality,
    bool convertToWebP = true,
    Function(int current, int total)? onProgress,
  }) async {
    final compressedFiles = <File>[];

    for (int i = 0; i < imageFiles.length; i++) {
      if (onProgress != null) {
        onProgress(i + 1, imageFiles.length);
      }

      final compressedFile = await compressImage(
        imageFile: imageFiles[i],
        targetSizeKB: targetSizeKB,
        quality: quality,
        convertToWebP: convertToWebP,
      );

      compressedFiles.add(compressedFile);
    }

    return compressedFiles;
  }

  // ==================== Image Validation ====================

  /// Check if file is an image
  bool isImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp']
        .contains(extension);
  }

  /// Check if image needs compression
  Future<bool> needsCompression(
    File imageFile, {
    int maxSizeKB = _maxImageSizeKB,
  }) async {
    try {
      if (!await imageFile.exists()) {
        return false;
      }

      final fileSize = await imageFile.length();
      final fileSizeKB = fileSize ~/ 1024;

      return fileSizeKB > maxSizeKB;
    } catch (e) {
      debugPrint('Error checking if compression needed: $e');
      return false;
    }
  }

  /// Get image dimensions
  Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return null;
      }

      // This is a placeholder - you would need to use a package like image
      // to get actual dimensions. For now, we'll return null.
      // You can add the 'image' package if you need this functionality.

      return null;
    } catch (e) {
      debugPrint('Error getting image dimensions: $e');
      return null;
    }
  }

  // ==================== PDF Compression ====================

  /// Compress PDF file (placeholder for future implementation)
  /// Note: PDF compression is complex and may require native libraries
  Future<File> compressPDF({
    required File pdfFile,
    int quality = 75,
  }) async {
    try {
      // Validate file exists
      if (!await pdfFile.exists()) {
        throw Exception('PDF file does not exist');
      }

      // Check file size
      final fileSize = await pdfFile.length();
      final fileSizeKB = fileSize ~/ 1024;

      debugPrint('PDF size: $fileSizeKB KB');

      // PDF compression is complex and typically requires native libraries
      // For now, we'll just return the original file
      // In a production app, you might want to use a service like:
      // - Cloud Functions to compress PDFs server-side
      // - Native PDF compression libraries
      // - Third-party PDF compression services

      debugPrint('PDF compression not implemented, returning original file');
      return pdfFile;
    } catch (e) {
      debugPrint('Error compressing PDF: $e');
      return pdfFile;
    }
  }

  // ==================== Utility Methods ====================

  /// Get file size in KB
  Future<int> getFileSizeKB(File file) async {
    try {
      if (!await file.exists()) {
        return 0;
      }

      final fileSize = await file.length();
      return fileSize ~/ 1024;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  /// Get file size in MB
  Future<double> getFileSizeMB(File file) async {
    try {
      if (!await file.exists()) {
        return 0.0;
      }

      final fileSize = await file.length();
      return fileSize / (1024 * 1024);
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0.0;
    }
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Clean up temporary compressed files
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = await tempDir
          .list()
          .where((entity) =>
              entity is File &&
              (entity.path.contains('_compressed') ||
                  entity.path.contains('_thumb')))
          .cast<File>()
          .toList();

      for (final file in files) {
        await file.delete();
      }

      debugPrint('Cleaned up ${files.length} temporary files');
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }
}

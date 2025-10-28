import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'firebase_service_manager.dart';
import 'file_compression_service.dart';

/// Service for handling Firebase Cloud Storage operations
/// Supports file uploads, downloads, and caching
class CloudStorageService {
  // Singleton instance
  static final CloudStorageService _instance = CloudStorageService._internal();

  factory CloudStorageService() => _instance;

  CloudStorageService._internal();

  // Convenience getter for singleton instance
  static CloudStorageService get instance => _instance;

  // Get Firebase Storage instance from service manager
  FirebaseStorage get _storage => FirebaseServiceManager.instance.storage;

  // Get compression service
  final FileCompressionService _compressionService =
      FileCompressionService.instance;

  // Cache management
  static const int _maxCacheSizeBytes = 100 * 1024 * 1024; // 100MB
  static const Duration _cacheExpiry = Duration(days: 7);

  // ==================== Upload Operations ====================

  /// Upload PDF file to Cloud Storage with progress tracking
  /// Returns the download URL of the uploaded file
  Future<String> uploadPDF({
    required String userId,
    required String reportId,
    required File pdfFile,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Validate file exists
      if (!await pdfFile.exists()) {
        throw Exception('PDF file does not exist');
      }

      // Create storage path
      final fileName = path.basename(pdfFile.path);
      final storagePath = 'reports/$userId/$reportId/$fileName';

      debugPrint('Uploading PDF to: $storagePath');

      // Get reference
      final ref = _storage.ref().child(storagePath);

      // Create upload task
      final uploadTask = ref.putFile(
        pdfFile,
        SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {
            'userId': userId,
            'reportId': reportId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadURL = await snapshot.ref.getDownloadURL();

      debugPrint('PDF uploaded successfully: $downloadURL');
      return downloadURL;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error uploading PDF: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error uploading PDF: $e');
      rethrow;
    }
  }

  /// Upload image file to Cloud Storage with compression
  /// Returns the download URL of the uploaded file
  Future<String> uploadImage({
    required String userId,
    required String reportId,
    required File imageFile,
    bool compress = true,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Compress image if needed
      File fileToUpload = imageFile;
      if (compress && _compressionService.isImageFile(imageFile)) {
        debugPrint('Compressing image before upload...');
        fileToUpload = await _compressionService.compressImage(
          imageFile: imageFile,
          convertToWebP: true,
        );
      }

      // Create storage path
      final fileName = path.basename(fileToUpload.path);
      final storagePath = 'reports/$userId/$reportId/$fileName';

      debugPrint('Uploading image to: $storagePath');

      // Get reference
      final ref = _storage.ref().child(storagePath);

      // Determine content type
      final extension = path.extension(fileName).toLowerCase();
      String contentType = 'image/jpeg';
      if (extension == '.png') {
        contentType = 'image/png';
      } else if (extension == '.webp') {
        contentType = 'image/webp';
      }

      // Create upload task
      final uploadTask = ref.putFile(
        fileToUpload,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'userId': userId,
            'reportId': reportId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'compressed': compress.toString(),
          },
        ),
      );

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadURL = await snapshot.ref.getDownloadURL();

      debugPrint('Image uploaded successfully: $downloadURL');
      return downloadURL;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error uploading image: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload generic file to Cloud Storage
  /// Returns the download URL of the uploaded file
  Future<String> uploadFile({
    required String storagePath,
    required File file,
    String? contentType,
    Map<String, String>? metadata,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Validate file exists
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      debugPrint('Uploading file to: $storagePath');

      // Get reference
      final ref = _storage.ref().child(storagePath);

      // Create metadata
      final uploadMetadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          ...?metadata,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Create upload task
      final uploadTask = ref.putFile(file, uploadMetadata);

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadURL = await snapshot.ref.getDownloadURL();

      debugPrint('File uploaded successfully: $downloadURL');
      return downloadURL;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error uploading file: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }

  // ==================== Download Operations ====================

  /// Get download URL for a file in Cloud Storage
  Future<String> getDownloadURL(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final downloadURL = await ref.getDownloadURL();
      debugPrint('Download URL retrieved: $downloadURL');
      return downloadURL;
    } on FirebaseException catch (e) {
      debugPrint(
          'Firebase error getting download URL: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      rethrow;
    }
  }

  /// Download file from Cloud Storage to local storage for offline access
  /// Returns the local file path
  Future<File> downloadFile({
    required String downloadURL,
    required String localFileName,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Get cache directory
      final cacheDir = await _getCacheDirectory();

      // Create local file path
      final localPath = path.join(cacheDir.path, localFileName);
      final localFile = File(localPath);

      // Check if file already exists in cache
      if (await localFile.exists()) {
        // Check if cache is still valid
        final fileStats = await localFile.stat();
        final age = DateTime.now().difference(fileStats.modified);

        if (age < _cacheExpiry) {
          debugPrint('File found in cache: $localPath');
          return localFile;
        } else {
          debugPrint('Cache expired, re-downloading file');
          await localFile.delete();
        }
      }

      // Extract storage path from download URL
      final storagePath = _extractStoragePathFromURL(downloadURL);

      if (storagePath == null) {
        throw Exception('Invalid download URL');
      }

      debugPrint('Downloading file from: $storagePath');

      // Get reference
      final ref = _storage.ref().child(storagePath);

      // Create download task
      final downloadTask = ref.writeToFile(localFile);

      // Listen to progress
      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for download to complete
      await downloadTask;

      debugPrint('File downloaded successfully: $localPath');

      // Clean up old cache files if needed
      await _cleanupCache();

      return localFile;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error downloading file: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      rethrow;
    }
  }

  // ==================== Delete Operations ====================

  /// Delete file from Cloud Storage
  Future<void> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
      debugPrint('File deleted successfully: $storagePath');
    } on FirebaseException catch (e) {
      debugPrint('Firebase error deleting file: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  /// Delete all files in a directory
  Future<void> deleteDirectory(String directoryPath) async {
    try {
      final ref = _storage.ref().child(directoryPath);
      final listResult = await ref.listAll();

      // Delete all files
      for (final item in listResult.items) {
        await item.delete();
        debugPrint('Deleted file: ${item.fullPath}');
      }

      // Recursively delete subdirectories
      for (final prefix in listResult.prefixes) {
        await deleteDirectory(prefix.fullPath);
      }

      debugPrint('Directory deleted successfully: $directoryPath');
    } on FirebaseException catch (e) {
      debugPrint('Firebase error deleting directory: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error deleting directory: $e');
      rethrow;
    }
  }

  // ==================== Cache Management ====================

  /// Get cache directory for storing downloaded files
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(path.join(appDir.path, 'firebase_cache'));

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// Clean up old cache files to maintain cache size limit
  Future<void> _cleanupCache() async {
    try {
      final cacheDir = await _getCacheDirectory();

      if (!await cacheDir.exists()) {
        return;
      }

      // Get all files in cache
      final files = await cacheDir
          .list(recursive: true)
          .where((entity) => entity is File)
          .cast<File>()
          .toList();

      // Calculate total cache size
      int totalSize = 0;
      final fileStats = <File, FileStat>{};

      for (final file in files) {
        final stats = await file.stat();
        fileStats[file] = stats;
        totalSize += stats.size;
      }

      // If cache size is within limit, no cleanup needed
      if (totalSize <= _maxCacheSizeBytes) {
        return;
      }

      debugPrint(
          'Cache size ($totalSize bytes) exceeds limit ($_maxCacheSizeBytes bytes), cleaning up...');

      // Sort files by last modified time (oldest first)
      files.sort((a, b) {
        final aStats = fileStats[a]!;
        final bStats = fileStats[b]!;
        return aStats.modified.compareTo(bStats.modified);
      });

      // Delete oldest files until cache size is within limit
      for (final file in files) {
        if (totalSize <= _maxCacheSizeBytes) {
          break;
        }

        final stats = fileStats[file]!;
        await file.delete();
        totalSize -= stats.size;
        debugPrint('Deleted cached file: ${file.path}');
      }

      debugPrint('Cache cleanup completed. New size: $totalSize bytes');
    } catch (e) {
      debugPrint('Error cleaning up cache: $e');
      // Don't rethrow - cache cleanup failure shouldn't block operations
    }
  }

  /// Clear all cached files
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('Cache cleared successfully');
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      rethrow;
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();

      if (!await cacheDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      final files = await cacheDir
          .list(recursive: true)
          .where((entity) => entity is File)
          .cast<File>()
          .toList();

      for (final file in files) {
        final stats = await file.stat();
        totalSize += stats.size;
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error getting cache size: $e');
      return 0;
    }
  }

  /// Check if file exists in cache
  Future<bool> isFileCached(String localFileName) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final localPath = path.join(cacheDir.path, localFileName);
      final localFile = File(localPath);

      if (!await localFile.exists()) {
        return false;
      }

      // Check if cache is still valid
      final fileStats = await localFile.stat();
      final age = DateTime.now().difference(fileStats.modified);

      return age < _cacheExpiry;
    } catch (e) {
      debugPrint('Error checking cache: $e');
      return false;
    }
  }

  /// Get cached file if it exists and is valid
  Future<File?> getCachedFile(String localFileName) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final localPath = path.join(cacheDir.path, localFileName);
      final localFile = File(localPath);

      if (!await localFile.exists()) {
        return null;
      }

      // Check if cache is still valid
      final fileStats = await localFile.stat();
      final age = DateTime.now().difference(fileStats.modified);

      if (age < _cacheExpiry) {
        return localFile;
      } else {
        // Cache expired, delete file
        await localFile.delete();
        return null;
      }
    } catch (e) {
      debugPrint('Error getting cached file: $e');
      return null;
    }
  }

  // ==================== Helper Methods ====================

  /// Extract storage path from Firebase Storage download URL
  String? _extractStoragePathFromURL(String downloadURL) {
    try {
      final uri = Uri.parse(downloadURL);

      // Firebase Storage URLs have the format:
      // https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?...
      final pathSegments = uri.pathSegments;

      if (pathSegments.length < 4 || pathSegments[0] != 'v0') {
        return null;
      }

      // Find the 'o' segment and get everything after it
      final oIndex = pathSegments.indexOf('o');
      if (oIndex == -1 || oIndex >= pathSegments.length - 1) {
        return null;
      }

      // Join all segments after 'o' and decode
      final encodedPath = pathSegments.sublist(oIndex + 1).join('/');
      return Uri.decodeComponent(encodedPath);
    } catch (e) {
      debugPrint('Error extracting storage path from URL: $e');
      return null;
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final metadata = await ref.getMetadata();
      return metadata;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting metadata: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error getting metadata: $e');
      rethrow;
    }
  }

  /// Update file metadata
  Future<void> updateFileMetadata(
    String storagePath,
    SettableMetadata metadata,
  ) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.updateMetadata(metadata);
      debugPrint('Metadata updated for: $storagePath');
    } on FirebaseException catch (e) {
      debugPrint('Firebase error updating metadata: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error updating metadata: $e');
      rethrow;
    }
  }

  /// List all files in a directory
  Future<List<Reference>> listFiles(String directoryPath) async {
    try {
      final ref = _storage.ref().child(directoryPath);
      final listResult = await ref.listAll();
      return listResult.items;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error listing files: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error listing files: $e');
      rethrow;
    }
  }
}

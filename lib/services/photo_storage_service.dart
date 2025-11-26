import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Service for photo storage and compression
class PhotoStorageService {
  static const int _thumbnailSize = 200;
  static const int _photoQuality = 70;

  /// Compress and save photo, return original and thumbnail paths
  Future<Map<String, String>> savePhoto(String originalPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${appDir.path}/receipts');

      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final uuid = const Uuid().v4();
      final photoPath = '${receiptsDir.path}/$uuid.jpg';
      final thumbnailPath = '${receiptsDir.path}/${uuid}_thumb.jpg';

      // Compress original photo
      final compressedPhoto = await FlutterImageCompress.compressAndGetFile(
        originalPath,
        photoPath,
        quality: _photoQuality,
      );

      if (compressedPhoto == null) {
        throw Exception('Failed to compress photo');
      }

      // Create thumbnail
      final thumbnail = await FlutterImageCompress.compressAndGetFile(
        originalPath,
        thumbnailPath,
        quality: _photoQuality,
        minWidth: _thumbnailSize,
        minHeight: _thumbnailSize,
      );

      if (thumbnail == null) {
        throw Exception('Failed to create thumbnail');
      }

      return {'photo': photoPath, 'thumbnail': thumbnailPath};
    } catch (e) {
      rethrow;
    }
  }

  /// Delete photo and thumbnail
  Future<void> deletePhoto(String photoPath, String? thumbnailPath) async {
    try {
      final photoFile = File(photoPath);
      if (await photoFile.exists()) {
        await photoFile.delete();
      }

      if (thumbnailPath != null) {
        final thumbnailFile = File(thumbnailPath);
        if (await thumbnailFile.exists()) {
          await thumbnailFile.delete();
        }
      }
    } catch (e) {
      // Silently fail on delete errors
    }
  }

  /// Get total storage used by receipts
  Future<int> getStorageUsed() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${appDir.path}/receipts');

      if (!await receiptsDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in receiptsDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Format bytes to human-readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

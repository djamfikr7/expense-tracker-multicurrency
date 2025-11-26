import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Service for managing camera operations
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;

  /// Initialize camera
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use back camera by default
      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Take a picture and return the path
  Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final image = await _controller!.takePicture();
      return image.path;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  /// Toggle flash mode
  Future<void> toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    final currentMode = _controller!.value.flashMode;
    final newMode = currentMode == FlashMode.off
        ? FlashMode.torch
        : FlashMode.off;

    try {
      await _controller!.setFlashMode(newMode);
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  /// Get current flash mode
  FlashMode get flashMode {
    return _controller?.value.flashMode ?? FlashMode.off;
  }

  /// Dispose camera controller
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/ocr_service.dart';
import '../services/photo_storage_service.dart';
import '../models/scanned_receipt.dart';
import 'package:uuid/uuid.dart';
import 'ocr_review_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final OcrService _ocrService = OcrService();
  final PhotoStorageService _photoService = PhotoStorageService();
  bool _isLoading = true;
  String? _error;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Camera not available: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capture photo
      final photoPath = await _cameraService.takePicture();

      if (photoPath == null) {
        throw Exception('Failed to capture photo');
      }

      // Save and compress photo
      final paths = await _photoService.savePhoto(photoPath);
      final savedPhotoPath = paths['photo']!;
      final thumbnailPath = paths['thumbnail']!;

      // Process with OCR
      final receiptId = const Uuid().v4();
      final scannedReceipt = await _ocrService.processImage(
        imagePath: savedPhotoPath,
        thumbnailPath: thumbnailPath,
        receiptId: receiptId,
      );

      // Navigate to review screen
      if (mounted) {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OcrReviewScreen(scannedReceipt: scannedReceipt),
          ),
        );

        if (result != null && mounted) {
          // Return OCR data to caller
          Navigator.pop(context, result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    await _cameraService.toggleFlash();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(body: Center(child: Text('Camera not available')));
    }

    final flashOn = _cameraService.flashMode == FlashMode.torch;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(child: CameraPreview(controller)),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Scan Receipt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Flash toggle
                    IconButton(
                      icon: Icon(
                        flashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Document overlay guide
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Position receipt\nwithin frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 64),

                    // Shutter button
                    GestureDetector(
                      onTap: _isProcessing ? null : _takePicture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isProcessing ? Colors.grey : Colors.white,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: _isProcessing
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 3,
                                ),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(width: 64),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

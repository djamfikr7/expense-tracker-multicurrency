import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/scanned_receipt.dart';

/// Service for OCR text recognition from images
class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Process image and extract receipt data
  Future<ScannedReceipt> processImage({
    required String imagePath,
    required String thumbnailPath,
    required String receiptId,
  }) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract fields from recognized text
      final fields = _extractFields(recognizedText);
      final confidence = _calculateConfidence(fields);

      return ScannedReceipt(
        id: receiptId,
        imagePath: imagePath,
        thumbnailPath: thumbnailPath,
        scannedAt: DateTime.now(),
        extractedFields: fields,
        confidenceScore: confidence,
        method: OcrMethod.onDevice,
        rawResponse: {'fullText': recognizedText.text},
        isVerified: false,
      );
    } catch (e) {
      // Return empty result on error
      return ScannedReceipt(
        id: receiptId,
        imagePath: imagePath,
        thumbnailPath: thumbnailPath,
        scannedAt: DateTime.now(),
        extractedFields: [],
        confidenceScore: 0.0,
        method: OcrMethod.onDevice,
        rawResponse: {'error': e.toString()},
        isVerified: false,
      );
    }
  }

  /// Extract structured fields from recognized text
  List<OcrField> _extractFields(RecognizedText recognizedText) {
    final fields = <OcrField>[];
    final fullText = recognizedText.text;

    // Extract amount
    final amountField = _extractAmount(fullText, recognizedText);
    if (amountField != null) fields.add(amountField);

    // Extract date
    final dateField = _extractDate(fullText, recognizedText);
    if (dateField != null) fields.add(dateField);

    // Extract merchant
    final merchantField = _extractMerchant(fullText, recognizedText);
    if (merchantField != null) fields.add(merchantField);

    return fields;
  }

  /// Extract amount from text using regex patterns
  OcrField? _extractAmount(String fullText, RecognizedText recognizedText) {
    // Common patterns: $XX.XX, XX.XX, TOTAL: XX.XX, etc.
    final patterns = [
      RegExp(r'\$\s*(\d+\.?\d{0,2})', caseSensitive: false),
      RegExp(r'total[:\s]*\$?\s*(\d+\.?\d{0,2})', caseSensitive: false),
      RegExp(r'amount[:\s]*\$?\s*(\d+\.?\d{0,2})', caseSensitive: false),
      RegExp(r'(\d+\.\d{2})\s*\$?', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(fullText);
      if (match != null && match.groupCount >= 1) {
        final value = match.group(1) ?? '';
        if (value.isNotEmpty) {
          return OcrField(
            fieldName: 'amount',
            value: value,
            confidence: 0.85,
            boundingBox: null,
          );
        }
      }
    }

    return null;
  }

  /// Extract date from text
  OcrField? _extractDate(String fullText, RecognizedText recognizedText) {
    // Common patterns: MM/DD/YYYY, DD-MM-YYYY, YYYY-MM-DD
    final patterns = [
      RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})'),
      RegExp(r'(\d{4}[/-]\d{1,2}[/-]\d{1,2})'),
      RegExp(
        r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{1,2},?\s+\d{4}',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(fullText);
      if (match != null && match.groupCount >= 1) {
        final value = match.group(1) ?? match.group(0) ?? '';
        if (value.isNotEmpty) {
          return OcrField(
            fieldName: 'date',
            value: value,
            confidence: 0.80,
            boundingBox: null,
          );
        }
      }
    }

    // Default to today if no date found
    return OcrField(
      fieldName: 'date',
      value: DateTime.now().toString().split(' ')[0],
      confidence: 0.50,
      boundingBox: null,
    );
  }

  /// Extract merchant name (usually first few lines)
  OcrField? _extractMerchant(String fullText, RecognizedText recognizedText) {
    final lines = fullText.split('\n');

    // Take first non-empty line as merchant name
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && trimmed.length > 2) {
        // Skip common receipt headers
        if (!trimmed.toLowerCase().contains('receipt') &&
            !trimmed.toLowerCase().contains('invoice')) {
          return OcrField(
            fieldName: 'merchant',
            value: trimmed,
            confidence: 0.70,
            boundingBox: null,
          );
        }
      }
    }

    return null;
  }

  /// Calculate average confidence score
  double _calculateConfidence(List<OcrField> fields) {
    if (fields.isEmpty) return 0.0;

    final sum = fields.fold<double>(
      0.0,
      (sum, field) => sum + field.confidence,
    );
    return sum / fields.length;
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}

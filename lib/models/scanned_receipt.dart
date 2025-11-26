import 'package:flutter/material.dart';

/// Represents a scanned receipt with OCR results
class ScannedReceipt {
  final String id;
  final String? transactionId; // Linked transaction
  final String imagePath; // Original photo path
  final String thumbnailPath; // 200x200 thumbnail
  final DateTime scannedAt;
  final List<OcrField> extractedFields;
  final double confidenceScore; // Average confidence
  final OcrMethod method;
  final Map<String, dynamic> rawResponse; // Raw OCR data
  final bool isVerified; // User confirmed accuracy

  const ScannedReceipt({
    required this.id,
    this.transactionId,
    required this.imagePath,
    required this.thumbnailPath,
    required this.scannedAt,
    required this.extractedFields,
    required this.confidenceScore,
    required this.method,
    required this.rawResponse,
    this.isVerified = false,
  });

  // Get specific extracted field
  OcrField? getField(String fieldName) {
    try {
      return extractedFields.firstWhere((f) => f.fieldName == fieldName);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'imagePath': imagePath,
      'thumbnailPath': thumbnailPath,
      'scannedAt': scannedAt.toIso8601String(),
      'extractedFields': extractedFields.map((f) => f.toJson()).toList(),
      'confidenceScore': confidenceScore,
      'method': method.toString(),
      'rawResponse': rawResponse,
      'isVerified': isVerified,
    };
  }

  factory ScannedReceipt.fromJson(Map<String, dynamic> json) {
    return ScannedReceipt(
      id: json['id'],
      transactionId: json['transactionId'],
      imagePath: json['imagePath'],
      thumbnailPath: json['thumbnailPath'],
      scannedAt: DateTime.parse(json['scannedAt']),
      extractedFields: (json['extractedFields'] as List)
          .map((e) => OcrField.fromJson(e))
          .toList(),
      confidenceScore: json['confidenceScore'],
      method: OcrMethod.values.firstWhere(
        (m) => m.toString() == json['method'],
        orElse: () => OcrMethod.onDevice,
      ),
      rawResponse: json['rawResponse'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  ScannedReceipt copyWith({
    String? id,
    String? transactionId,
    String? imagePath,
    String? thumbnailPath,
    DateTime? scannedAt,
    List<OcrField>? extractedFields,
    double? confidenceScore,
    OcrMethod? method,
    Map<String, dynamic>? rawResponse,
    bool? isVerified,
  }) {
    return ScannedReceipt(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      scannedAt: scannedAt ?? this.scannedAt,
      extractedFields: extractedFields ?? this.extractedFields,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      method: method ?? this.method,
      rawResponse: rawResponse ?? this.rawResponse,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

/// Individual extracted field from OCR
class OcrField {
  final String fieldName; // amount, date, merchant, category
  final String value;
  final double confidence; // 0.0 to 1.0
  final Rect? boundingBox; // Position in image

  const OcrField({
    required this.fieldName,
    required this.value,
    required this.confidence,
    this.boundingBox,
  });

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'value': value,
      'confidence': confidence,
      'boundingBox': boundingBox != null
          ? {
              'left': boundingBox!.left,
              'top': boundingBox!.top,
              'right': boundingBox!.right,
              'bottom': boundingBox!.bottom,
            }
          : null,
    };
  }

  factory OcrField.fromJson(Map<String, dynamic> json) {
    return OcrField(
      fieldName: json['fieldName'],
      value: json['value'],
      confidence: json['confidence'],
      boundingBox: json['boundingBox'] != null
          ? Rect.fromLTRB(
              json['boundingBox']['left'],
              json['boundingBox']['top'],
              json['boundingBox']['right'],
              json['boundingBox']['bottom'],
            )
          : null,
    );
  }
}

/// OCR processing method
enum OcrMethod {
  onDevice, // ML Kit on-device
  cloud, // Cloud OCR API
  manual, // Manual entry
}

/// Receipt processing status
enum ReceiptStatus { pending, processing, completed, error }

/// Payment proof status for transactions
enum PaymentProofStatus {
  none, // No receipt attached
  pending, // Photo attached, not processed
  processing, // OCR in progress
  verified, // OCR matched transaction
  mismatch, // OCR found discrepancies
  manual, // User manually verified
}

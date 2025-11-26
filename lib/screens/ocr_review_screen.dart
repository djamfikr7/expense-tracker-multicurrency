import 'package:flutter/material.dart';
import '../models/scanned_receipt.dart';
import '../services/app_localizations.dart';

class OcrReviewScreen extends StatefulWidget {
  final ScannedReceipt scannedReceipt;

  const OcrReviewScreen({super.key, required this.scannedReceipt});

  @override
  State<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends State<OcrReviewScreen> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = {};
    for (final field in widget.scannedReceipt.extractedFields) {
      _controllers[field.fieldName] = TextEditingController(text: field.value);
    }

    // Ensure all required fields have controllers
    if (!_controllers.containsKey('amount')) {
      _controllers['amount'] = TextEditingController();
    }
    if (!_controllers.containsKey('date')) {
      _controllers['date'] = TextEditingController();
    }
    if (!_controllers.containsKey('merchant')) {
      _controllers['merchant'] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _confirm() {
    final data = {
      'amount': _controllers['amount']?.text ?? '',
      'date': _controllers['date']?.text ?? '',
      'merchant': _controllers['merchant']?.text ?? '',
      'receiptPath': widget.scannedReceipt.imagePath,
      'thumbnailPath': widget.scannedReceipt.thumbnailPath,
      'scannedReceiptId': widget.scannedReceipt.id,
    };

    Navigator.pop(context, data);
  }

  void _retake() {
    Navigator.pop(context);
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.8) return Icons.check_circle;
    if (confidence >= 0.6) return Icons.warning;
    return Icons.error;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confidence Scores'),
                  content: const Text(
                    '✓ Green: High confidence (>80%)\n'
                    '⚠ Orange: Medium confidence (60-80%)\n'
                    '✗ Red: Low confidence (<60%)\n\n'
                    'Please verify all extracted data before confirming.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Receipt image preview
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: Image.asset(
              widget.scannedReceipt.thumbnailPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.receipt, size: 64, color: Colors.grey),
                );
              },
            ),
          ),

          // Extracted fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extracted Data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Amount field
                  _buildField(
                    'amount',
                    localizations.translate('amount'),
                    Icons.attach_money,
                    TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Date field
                  _buildField(
                    'date',
                    localizations.translate('date'),
                    Icons.calendar_today,
                    TextInputType.datetime,
                  ),
                  const SizedBox(height: 16),

                  // Merchant field
                  _buildField(
                    'merchant',
                    'Merchant',
                    Icons.store,
                    TextInputType.text,
                  ),

                  const SizedBox(height: 24),

                  // Confidence score
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.analytics, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Overall Confidence: ${(widget.scannedReceipt.confidenceScore * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retake,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String fieldName,
    String label,
    IconData icon,
    TextInputType keyboardType,
  ) {
    final field = widget.scannedReceipt.getField(fieldName);
    final confidence = field?.confidence ?? 0.0;

    return TextField(
      controller: _controllers[fieldName],
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: Icon(
          _getConfidenceIcon(confidence),
          color: _getConfidenceColor(confidence),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

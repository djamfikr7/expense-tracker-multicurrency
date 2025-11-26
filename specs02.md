Expense Tracker with Advanced Currency Management (concerns only teh pro version)
Enhanced Product Requirements Document & Technical Specifications
Version: 2.1 | Last Updated: November 25, 2025 | Platform: Flutter (Cross-platform)
📋 Table of Contents
Executive Summary
Product Vision & Goals
Current Features
Technical Architecture
Data Models
User Flows
UI/UX Specifications
Currency Management System
Localization & Internationalization
Security & Privacy
Analytics & Telemetry
Error Handling & Resilience
Future Enhancement Opportunities
Technical Debt & Known Issues
API Specifications
Non-Functional Requirements
Platform-Specific Considerations
Monetization Strategy
Competitive Analysis
Conclusion & Recommendations
Appendix
1. Executive Summary
1.2 Key Differentiators
Dual Exchange Rate System: Supports both official and parallel market rates
AI-Powered OCR Scanning: Direct document scanning with automatic data extraction
Universal File Import/Export: CSV, Excel, PDF with intelligent field mapping
Real-time Currency Conversion: Transactions automatically convert to base currency
Built-in Calculator: Integrated with memory and currency conversion
Offline-First: Local storage with encrypted cloud sync
Multi-Language Support: English, French, Arabic, Chinese + Spanish, Portuguese
Bank-Level Security: AES-256 encryption, biometric authentication
Automated Smart Alerts: Budget, rate change, and bill reminder notifications
Historical Analytics: Interactive charts with trend analysis and forecasting
3. Current Features
3.1 Core Financial Features
3.1.1 Transaction Management
Transaction Details:
Amount (original currency)
Currency (ISO 4217)
Category & tags
Date & time
Description
Payment method
Merchant name with auto-complete
GPS location (privacy-controlled)
[NEW] Photo attachments: Receipt/ticket photos with EXIF data
[NEW] Scanned document ID: Link to OCR-processed document
[NEW] Payment proof status: Verified, Unverified, Pending Review
Recurring settings
Split transactions: Up to 5 categories per transaction
[NEW] Linked documents: Multiple photos per transaction
3.1.3 Dashboard & Analytics
Summary Cards: Income, Expenses, Net Balance with trend indicators
Income vs Expense Pie Chart: Animated with percentage breakdowns
Expense Breakdown: Category-wise with progress bars
[NEW] Historical Line Charts: 30/90/365-day trends for income/expenses
[NEW] Interactive Time Series: Pinch-to-zoom, pan, tap for details
[NEW] Cumulative Flow Diagram: Show spending velocity over time
[NEW] Top Merchants Chart: Horizontal bar chart of frequent vendors
[NEW] Currency Exposure Pie Chart: Portfolio distribution by currency
[NEW] Forecasting: ML-based spending predictions (dashed line overlay)
[NEW] Anomaly Detection: Highlight unusual spending patterns
All charts support export as PNG/PDF
3.2 Currency Management Features
3.2.2 Exchange Rate Management
Rate Sources: API, hardcoded defaults, manual override, community
Auto-Update:
[ENHANCED] Background sync: Configurable intervals (1h, 6h, 12h, 24h)
[NEW] Push notifications: Alert when premium changes >5%
[NEW] Rate alerts: User-set thresholds (e.g., "Notify when EUR/DZD > 280")
[NEW] Daily digest: Morning summary of rate changes
Confidence Indicators: Color-coded reliability scores
[NEW] Historical Rate Charts: Interactive charts showing 1-year rate history
[NEW] Volatility Index: Visual gauge showing rate stability
3.3 Utility Features
3.3.1 Built-in Calculator
[ENHANCED] Currency Conversion Mode: Live rate display during calculation
[NEW] Expression History: Last 100 calculations with timestamps
[NEW] Scientific Mode: Advanced functions for power users
3.3.2 Search & Filtering
[ENHANCED] Full-text search: Across descriptions, merchants, categories, tags
[NEW] Image Search: Search by receipt photo content (OCR text index)
[NEW] Location-based filtering: "Show expenses within 1km"
3.3.3 Data Export & Import [MAJOR ENHANCEMENT]
Export Capabilities:
CSV: Customizable fields, delimiters, date formats
Options: Include receipts as base64, separate attachments folder
Excel (.xlsx): Multi-sheet workbook
Sheet 1: Transactions
Sheet 2: Budgets
Sheet 3: Currency rates history
Sheet 4: Summary statistics with pivot tables
PDF: Professional formatted reports
Include charts, receipts, category breakdowns
Password protection option
Digital signature for audit trail
JSON: Complete data dump with metadata
QIF/OFX: Bank-compatible formats for reconciliation
[NEW] QuickBooks Integration: Direct export to .QBO format
[NEW] Google Sheets: Live sync to specific sheet
Import Capabilities:
CSV/Excel: Intelligent field mapping wizard
Auto-detect columns: amount, date, category, currency
Preview first 10 rows before import
Handle multiple date formats (MM/DD/YYYY, DD/MM/YYYY, ISO)
Currency detection from symbols ($, €, د.ج)
Duplicate detection based on amount/date/merchant
[NEW] Bank Statements: PDF/CSV import with automatic parsing
Support for major banks: Chase, Bank of America, HSBC, etc.
Auto-categorization based on merchant MCC codes
[NEW] Third-party Apps: Import from Mint, YNAB, Wallet
Guided migration tool with data validation
Progress bar for large imports (>10k transactions)
Export/Import Features:
Scheduled Export: Automatic weekly/monthly email export
Cloud Export: Direct to Google Drive, Dropbox, iCloud
Template System: Save export configurations as reusable templates
Batch Operations: Export only filtered results
Encryption: Optional ZIP with AES-256 password for sensitive exports
3.3.4 AI-Powered Document Scanner [NEW SECTION]
OCR & Scanning Pipeline:
[NEW] Camera Integration: Native camera with custom overlay
Real-time edge detection for receipts
Auto-capture when document detected
Flash/torch control, focus lock
Multiple photo burst mode for best quality
[NEW] Document Types Supported:
Receipts (restaurant, retail, gas)
Invoices (utility bills, subscriptions)
Bank statements (account activity)
Tickets (travel, events)
QR codes (payment confirmations)
[NEW] OCR Processing:
On-device: ML Kit (Google) / Vision Framework (Apple) for privacy
Cloud fallback: Microsoft Azure Form Recognizer (opt-in)
Extracted Fields: Amount, date, merchant, category, items (line-level)
Confidence Score: Per-field accuracy indicator (0-100%)
Manual Review: Edit extracted data before saving
[NEW] Receipt Intelligence:
Auto-categorize based on merchant name
Detect payment method from receipt text ("Cash", "Visa ****1234")
Split items into multiple transactions
VAT/Tax extraction for business users
[NEW] Storage Management:
Compress photos to 70% quality JPEG (balance size/quality)
Thumbnail generation (200x200) for list view
Cloud backup of photos (Premium feature)
Storage usage indicator in settings
Auto-delete old photos after 2 years (configurable)
[NEW] Search & Retrieval:
OCR text indexed for search
Visual search: "Find all coffee receipts"
Receipt gallery view for transaction
Share receipt as image/PDF
3.3.5 Settings & Preferences
[ENHANCED] Data Management:
Storage Usage: Visual breakdown (Transactions: 45MB, Photos: 120MB, etc.)
Auto-Delete: Purge transactions older than 1/2/5 years
Photo Quality: Original, High (70%), Medium (50%), Low (30%)
[NEW] OCR Language: Select OCR language packs (download for offline)
[NEW] Auto-Scan: Auto-process photos immediately vs manual trigger
[NEW] Duplicate Detection: Aggressive/Standard/Disabled matching
3.4 Data Management
3.4.1 Storage
[ENHANCED] Multi-tier storage:
Active Data: SQLite for transactions, budgets, settings
Media: File system for receipt photos (external storage with scoped permissions)
Cache: EncryptedSharedPreferences for API responses
Backup: Compressed JSON archives with versioning
Sync Queue: SQLite table for pending cloud sync operations
3.4.2 Data Integrity
[NEW] Photo Integrity: SHA-256 checksum for receipt photos
[NEW] OCR Data Validation: Cross-check extracted amount with transaction amount
[NEW] Import Validation: Dry-run import counting successes/warnings/errors
4. Technical Architecture
4.1 Application Structure
Copy
lib/
├── core/
│   ├── constants/                 # Export/import formats, OCR languages
│   └── utils/
│       ├── csv_parser.dart        # **[NEW] CSV/Excel parsing
│       ├── ocr_engine.dart        # **[NEW] OCR abstraction layer
│       └── file_exporter.dart     # **[NEW] Export orchestration
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── drift_database.dart   # SQLite with transaction photos BLOB
│   │   └── remote/
│   │       └── ocr_api.dart          # **[NEW] Cloud OCR service
│   └── repositories/
│       ├── import_repository.dart    # **[NEW] Import coordination
│       └── export_repository.dart    # **[NEW] Export coordination
├── domain/
│   └── entities/
│       ├── scanned_document.dart     # **[NEW] OCR result entity
│       └── export_template.dart      # **[NEW] Export configuration
├── presentation/
│   ├── blocs/
│   │   ├── import/                   # **[NEW] Import BLoC with progress
│   │   └── ocr/                      # **[NEW] OCR processing BLoC
│   └── screens/
│       ├── scanner/                  # **[NEW] Camera overlay screen
│       ├── import_wizard/            # **[NEW] Step-by-step import UI
│       └── export_config/            # **[NEW] Export options screen
└── services/
    ├── camera_service.dart           # **[NEW] Camera controller
    ├── ocr_service.dart              # **[NEW] On-device OCR
    ├── export_service.dart           # **[NEW] Export file generation
    ├── notification_service.dart     # **[ENHANCED] Local/push notifications
    └── sync_service.dart             # Enhanced with conflict resolution
4.3 Dependencies
yaml
Copy
dependencies:
  # Existing dependencies...
  
  # **[NEW] File Import/Export**
  csv: ^5.1.1
  excel: ^4.0.0
  pdf: ^3.10.0
  printing: ^5.11.0
  archive: ^3.4.0
  share_plus: ^7.1.0
  
  # **[NEW] OCR & Camera**
  camera: ^0.10.5+2
  google_mlkit_text_recognition: ^0.11.0
  google_mlkit_document_scanner: ^0.1.0
  image_picker: ^1.0.4
  path_provider: ^2.1.1
  flutter_image_compress: ^2.0.4
  
  # **[NEW] Notifications**
  flutter_local_notifications: ^16.1.0
  awesome_notifications: ^0.8.2
  timezone: ^0.9.2
  
  # **[NEW] Charts & Visualization**
  syncfusion_flutter_charts: ^23.1.0  # Advanced interactive charts
  fl_chart: ^0.63.0                   # Existing charts
  
  # **[NEW] Background Processing**
  workmanager: ^0.5.1
  background_downloader: ^8.5.0
5. Data Models
5.1 Transaction Model
dart
Copy
class Transaction extends Equatable {
  // ... existing fields
  
  // **[NEW] Document References**
  final List<String> receiptPhotoPaths;        // List of image file paths
  final String? scannedDocumentId;             // FK to ScannedDocument
  final PaymentProofStatus proofStatus;        // Enum: verified, pending, none
  final Map<String, dynamic>? ocrRawData;      // Full OCR extraction results
}

class PaymentProofStatus extends Enum {
  static const none = PaymentProofStatus(0);      // No receipt attached
  static const pending = PaymentProofStatus(1);   // Photo attached, not processed
  static const processing = PaymentProofStatus(2); // OCR in progress
  static const verified = PaymentProofStatus(3);   // OCR matched transaction
  static const mismatch = PaymentProofStatus(4);   // OCR found discrepancies
  static const manual = PaymentProofStatus(5);    // User manually verified
}
5.5 Scanned Document Model [NEW]
dart
Copy
class ScannedDocument extends Equatable {
  final String id;                    // UUID
  final String? transactionId;        // Linked transaction
  final String imagePath;             // Original photo path
  final String thumbnailPath;         // 200x200 thumbnail
  final DateTime scannedAt;           // Scan timestamp
  final List<OcrField> extractedFields; // OCR results
  final double confidenceScore;       // Average confidence
  final OcrProcessingMethod method;   // on_device or cloud
  final Map<String, dynamic> rawResponse; // Raw OCR data
  final bool isVerified;              // User confirmed accuracy
}

class OcrField extends Equatable {
  final String fieldName;            // amount, date, merchant, etc.
  final String value;                // Extracted text
  final double confidence;           // 0.0 to 1.0
  final Rect boundingBox;            // Position in image
}
6. User Flows
6.2 Adding a Transaction
[ENHANCED] Scanner-First Flow:
Tap FAB → Choice dialog: "Scan Receipt" / "Manual Entry"
If Scan Receipt:
Open camera with document overlay guide
Auto-detect edges, auto-capture when stable
Preview screen with "Retake" / "Use Photo"
Show OCR processing spinner (2-5 seconds)
OCR results screen: extracted fields + confidence scores
User can edit any field, tap field to zoom image
Tap "Confirm" → Transaction created with photo attached
Return to dashboard with "Scan Successful" snackbar
6.7 Import Data Flow [NEW]
Step-by-step wizard:
Settings → "Import Data"
Source Selection:
CSV/Excel file
Bank statement PDF
Third-party app (Mint, YNAB)
File Picker:
System file picker or drag-and-drop (desktop)
Show file size and format validation
Column Mapping:
Auto-detect columns using ML
Visual mapping interface: "App Field → File Column"
Preview table with first 5 rows
Save mapping as template for future imports
Import Preview:
Show statistics: Total rows, Valid, Warnings, Errors
Warnings: Currency not found, Future dates, Duplicate detection
Errors: Required fields missing, Invalid amount format
Import Execution:
Progress bar with live count
Cancelable operation
Handle duplicates: Skip / Update / Create new
Import Summary:
Success count, Failed count
"View imported transactions" button
"Download error report" for failed rows
6.8 Export Data Flow [NEW]
Flexible export:
Transactions tab → Filter → "Export"
Format Selection: CSV, Excel, PDF, JSON
Options:
Date range
Include receipts (ZIP file)
Password protect
Template selection
Preview: Show estimated file size
Generation: Progress indicator (large exports can take 10-30s)
Share Sheet: Save to Files, Email, Google Drive, Dropbox, AirDrop
6.9 Camera & Scanner Flow [NEW]
Dedicated scanner mode:
Calculator → "Scan Mode" or Quick Action "Scan Receipt"
Camera Screen:
Top bar: Flash, Auto/Manual mode, Gallery picker
Center: Document boundary overlay (animated)
Bottom: Shutter button, Batch mode toggle
Batch Scanning:
Scan multiple receipts in sequence
Preview gallery at bottom
Process all when done
Review Screen:
Swipe between scanned documents
Each shows extracted data
Bulk approve or edit individually
Save Options:
Save all as individual transactions
Merge into single transaction (e.g., one store, multiple receipts)
Save to draft for later review
7. UI/UX Specifications
7.4 Component Library
7.4.6 Camera & Scanner Components [NEW]
dart
Copy
// Document Scanner Overlay
class ScannerOverlay extends StatelessWidget {
  final List<Point> detectedEdges;
  final bool isStable;
  final VoidCallback onCapture;
  
  // Features:
  // - Pulsing animation when document detected
  // - Corner handles for manual adjustment (after capture)
  // - Perspective correction preview
  // - Multi-page indicator ("Page 2 of 3")
}

// OCR Result Review Card
class OcrReviewCard extends StatelessWidget {
  final OcrField field;
  final VoidCallback onEdit;
  final VoidCallback onZoom;
  
  // Features:
  // - Confidence indicator (green/yellow/red dot)
  // - Tap to highlight in original image
  // - Edit icon shows keyboard
  // - Zoom icon shows full-screen image crop
}

// Import Progress Dialog
class ImportProgressDialog extends StatelessWidget {
  final int total;
  final int processed;
  final int errors;
  final bool isIndeterminate;
  
  // Features:
  // - Percentage progress bar
  // - Live counts: "Processing row 1,247 of 5,000"
  // - Error log expandable section
  // - Cancel button (stops gracefully)
}
7.4.7 Notification Components [NEW]
dart
Copy
// Rate Alert Banner
class RateAlertBanner extends StatelessWidget {
  final String currencyCode;
  final double changePercent;
  final VoidCallback onDismiss;
  
  // Features:
  // - Slide-down animation
  // - Color coded: green (good), red (bad)
  // - "View Details" button opens rate chart
  // - Swipe to dismiss
}

// Budget Warning Chip
class BudgetWarningChip extends StatelessWidget {
  final String category;
  final double spentPercent;
  
  // Features:
  // - Animated progress ring
  // - Tap to see remaining amount
  // - Changes color at 50/80/100%
}
7.5 Animations
[ENHANCED] Scanner animations:
Document Detection: Blue pulse around detected edges
Auto-Capture: Shutter animation + haptic + success sound
OCR Processing: Rotating scanner icon with progress dots
Import: Checkmark cascade as rows complete
Export: Progress bar with file icon filling up
Rate Alert: Gentle bounce effect when banner appears
8. Currency Management System
8.2 Exchange Rate Flow
[ENHANCED] With notifications:
Mermaid
Fullscreen 
Download 
Copy
Code
Preview
8.7 Confidence Indicators [ENHANCED]
[NEW] Rate Alert Thresholds:
User Alerts: Custom thresholds per currency
Example: "Alert me when DZD premium exceeds 90%"
System Alerts: Automatic for all users
Volatility spike: >3% change in 1 hour
API failure: Switching to fallback source
Notification Channels:
High Priority: Rate volatility, budget overage (sound + popup)
Normal Priority: Daily digest, background sync (silent notification)
Low Priority: Tips, reminders (no sound, banner only)
9. Localization & Internationalization
9.2 Translation Management
[ENHANCED] OCR language support:
Table
Copy
Language	OCR Support	Download Size	Model Type
English	✅	15MB	On-device
French	✅	18MB	On-device
Arabic	✅	22MB	On-device
Chinese	✅	25MB	On-device
Spanish	✅	19MB	On-device
Portuguese	✅	17MB	On-device
10. Security & Privacy
10.3 Privacy Controls
[ENHANCED] Document scanning privacy:
On-device OCR: Default, no data leaves device
Cloud OCR: Opt-in only, encrypted transmission
Photo Storage:
Local only (Free tier)
Encrypted cloud backup (Premium)
Auto-delete from device after cloud upload (configurable)
EXIF Data: GPS stripped by default, optional retention
Receipt Data: Merchant names anonymized in analytics
11. Analytics & Telemetry
11.2 Event Tracking [ENHANCED]
Table
Copy
Event Name	Properties	Trigger
receipt_scanned	ocr_method, confidence, processing_time	OCR completes
export_created	format, includes_receipts, file_size	Export successful
import_started	source, row_count	User begins import
import_completed	success_count, error_count, duration	Import finishes
rate_alert_triggered	currency, change_percent	User threshold met
budget_alert_sent	category, spent_percent	Budget notification sent
camera_permission_denied	context	Scanner can't access camera
12. Error Handling & Resilience
12.1 Error Classification [ENHANCED]
Table
Copy
Error Type	Examples	User Message	Recovery
Camera Error	Permission denied, hardware unavailable	"Camera not available"	Show manual entry fallback
OCR Error	Low light, blurry image, unsupported language	"Unable to read receipt"	Request retake or manual entry
Import Error	Malformed CSV, missing columns, encoding issues	"Import failed: [specific reason]"	Show error row details, allow download of problematic rows
Export Error	Storage full, permission denied, format error	"Export failed"	Free space, retry, alternative format
Rate Alert Error	Notification permission denied	"Enable notifications in settings"	Deep link to settings
Sync Error	Conflict, network, authentication	"Sync pending... will retry"	Queue for retry, show status indicator
12.2 OCR Error Recovery [NEW]
Low Confidence (<60%): Highlight uncertain fields in yellow, require manual review
Unreadable Amount: Show cropped image section, ask user to type amount
Missing Date: Default to today's date, allow tap to change
Wrong Language: Auto-detect language, download model if needed
Blurry Image: "Image too blurry. Retake?" with before/after preview
12.3 Import Validation Errors [NEW]
dart
Copy
class ImportError {
  final int rowNumber;
  final String column;
  final String value;
  final String errorType; // 'invalid_amount', 'future_date', 'unknown_currency'
  final String suggestion; // "Try format: 123.45"
}

// Error Report Generation
// Download as CSV: row_number, column, value, error, suggestion
13. Future Enhancement Opportunities
13.1 High-Priority Features
13.1.6 AI Document Processing Pipeline [NEW]
Smart Receipt Categorization: Train model on user corrections
Line Item Extraction: Split grocery bills into multiple categories
Merchant Logo Recognition: Auto-identify store from logo
Handwriting Recognition: Support for hand-written receipts
Multi-language Receipts: Detect and process mixed-language documents
13.1.7 Advanced Notifications System [NEW]
Bill Reminders: OCR extracts due dates from bills, creates reminders
Recurring Payment Detection: Scan identifies subscription payments
Price Comparison: Alert if same item purchased at higher price elsewhere
Duplicate Detection: Warn if same receipt scanned twice
13.3 Currency System Enhancements
[NEW] Historical Chart Export: Export rate charts as PDF/PNG for reports
[NEW] Rate Alert Dashboard: Manage all alerts in one screen
14. Technical Debt & Known Issues
14.5 OCR & Camera Issues [NEW]
Table
Copy
Issue	Severity	Impact	Effort	Fix Version
Camera crashes on low-end devices	🟡 Medium	User frustration	2 weeks	v2.2
OCR poor performance on Arabic receipts	🟡 Medium	Localization gap	3 weeks	v2.3
Large photo files cause storage bloat	🟢 Low	Storage usage	1 week	v2.1
Batch scanning memory leak	🔴 High	App crash	1 week	v2.1
15. API Specifications
15.4 OCR Cloud API [NEW]
Endpoint: POST https://ocr.expensetracker.com/v1/recognize
Auth: Bearer token (Premium users only)
Headers: Content-Type: multipart/form-data
Request:
JSON
Copy
{
  "image": <binary>,
  "language": "auto",
  "extract_fields": ["amount", "date", "merchant", "items"],
  "confidence_threshold": 0.7
}
Response:
JSON
Copy
{
  "document_id": "ocr-123",
  "extracted_fields": {
    "amount": {"value": "23.45", "confidence": 0.95},
    "date": {"value": "2025-11-25", "confidence": 0.98},
    "merchant": {"value": "STARBUCKS", "confidence": 0.89}
  },
  "line_items": [...],
  "processing_time_ms": 1200,
  "credits_used": 1
}
Rate Limit: 100 scans/month (Premium), 500/month (Pro)
16. Non-Functional Requirements
16.1 Performance
[ENHANCED] Scanner performance:
OCR Processing: <3 seconds on-device, <1 second cloud (p95)
Photo Capture: <500ms shutter-to-preview
Batch Scan: 10 receipts in <20 seconds
Import Speed: 1000 rows/minute for CSV/Excel
Export Speed: 5000 transactions/minute to Excel
16.3 Usability
Scanner Learning Curve: <2 minutes to scan first receipt (tutorial)
Import Success Rate: >95% of valid files import without errors
OCR Accuracy: >85% field extraction accuracy (prominent merchants)
Photo Storage: Average receipt photo: 150KB (compressed)
17. Platform-Specific Considerations
17.1 iOS
Scanner: Vision framework with VNRecognizedText
Live Text: iOS 16+ Live Text integration (tap camera view to use)
Shortcuts: "Scan Receipt" Siri shortcut with parameter for category
Photos Extension: Import receipts directly from Photos app
Files Integration: Import CSV from Files app share sheet
17.2 Android
Scanner: ML Kit Text Recognition v2 (on-device)
Camera2 API: Advanced controls (exposure, focus, white balance)
Storage Access Framework: SAF for file picker (Android 11+)
Share Sheet: Direct share to app from gallery/file manager
WorkManager: Background export/import with progress notifications
17.3 Web
[NEW] File System Access API: Direct read/write for CSV/Excel
[NEW] WebRTC: Camera access for receipt scanning
[NEW] Web Share API: Share export files natively
[NEW] Clipboard API: Paste receipt images from clipboard
IndexedDB: Store receipt photos (100MB limit per domain)
PWA: Installable, works offline for viewing data
17.4 Desktop
[NEW] File System Integration: File watchers for auto-import folders
[NEW] System Notifications: Native OS notifications for alerts
[NEW] Drag & Drop: Drag CSV/receipts into app window
[NEW] Print to PDF: Direct printing of reports
[NEW] Keyboard Shortcuts:
Ctrl/Cmd + E: Export
Ctrl/Cmd + I: Import
Ctrl/Cmd + Shift + S: Open scanner
18. Monetization Strategy
18.1 Freemium Model [ENHANCED]
18.1.1 Free Tier
Scanning: 20 OCR scans/month (on-device only)
Export: CSV only, max 1000 transactions
Import: CSV only, max 500 rows at once
Photos: Local storage, 50 receipt limit
18.1.2 Premium Tier ($4.99/month)
Scanning: 200 OCR scans/month (cloud + on-device)
Export: All formats, unlimited
Import: All formats, unlimited rows
Photos: Encrypted cloud backup, 500 receipt limit
Alerts: Custom rate alerts, budget notifications
18.1.3 Pro Tier ($9.99/month)
Scanning: Unlimited OCR
Photos: Unlimited cloud storage
API: Access to OCR API for external automation
Priority: Higher rate API quota
18.2 OCR Credit System [NEW]
On-device scans: Free, unlimited (all tiers)
Cloud scans:
Premium: 200 credits/month
Pro: 1000 credits/month
Additional credits: $0.05/scan
Credit Rollover: Up to 2x monthly limit
20. Conclusion & Recommendations
20.1 Immediate Actions (Next 2 Weeks) [UPDATED]
Camera Integration: Implement basic receipt capture
CSV Export: Release MVP export feature
OCR Prototype: Integrate ML Kit for on-device processing
Error Handling: Add global error boundary with user-friendly messages
Notification System: Setup local notifications for budget alerts
20.2 3-Month Roadmap [ENHANCED]
Month 1: Core & Stability
Receipt scanning with on-device OCR
CSV/Excel import wizard
Transaction editing with audit trail
Storage migration to SQLite
Automated rate updates with notifications
Month 2: Power User Features
Excel/PDF export with charts
Advanced filters and saved searches
Bulk operations (edit, delete, categorize)
Cloud OCR for Premium users
Background sync and import/export
Month 3: Polish & Monetization
Batch scanning mode
Import from bank statements
Smart alerts (bills, duplicates, price changes)
Launch Premium tier with cloud sync
Advanced analytics dashboard
20.3 Success Metrics for New Features [NEW]
Table
Copy
Feature	Target Metric	Measurement
Receipt Scanning	40% of transactions include photo	Analytics event
OCR Accuracy	>85% field extraction	User corrections tracked
Import Usage	25% of users import historical data	Import completion events
Export Usage	15% of users export monthly	Export format distribution
Rate Alerts	30% of users set custom alerts	Alert creation events
Notification Engagement	60% click-through rate	Notification analytics
21. Appendix
21.4 Export/Import File Specifications [NEW]
CSV Format
csv
Copy
date,category,amount,currency,description,merchant,payment_method,tags,receipt_path
2025-11-25,Food & Dining,25.99,USD,Lunch,Starbucks,card,"coffee,work",/photos/receipt1.jpg
Excel Format
Sheet 1: Transactions: Same columns as CSV
Sheet 2: Budgets: category,amount,period,spent
Sheet 3: Summary: Pivot table by category, monthly totals
Sheet 4: Charts: Embedded charts (pie, line)
PDF Report Layout
Copy
[Header] Expense Report | Nov 2025
[Summary Cards] Income: $5,000 | Expenses: $3,200 | Net: $1,800
[Charts] Pie: Expense Breakdown | Line: Spending Trend
[Table] All transactions with receipts as thumbnails
[Footer] Generated by Expense Tracker | Page 1 of 5
21.5 Scanner User Guide (Help Article) [NEW]
Best Practices for Receipt Scanning:
Lighting: Use natural light, avoid shadows
Angle: Hold camera parallel to receipt
Distance: Fill 80% of frame, not too close
Clarity: Ensure text is in focus (tap to focus)
Flat Receipt: Smooth out wrinkles, flatten on table
Multiple Items: Use batch mode for long receipts
Troubleshooting: Low confidence? Retake with better lighting
Document Version History
Table
Copy
Version	Date	Author	Key Additions
1.0	Nov 25, 2025	Initial	Initial baseline
2.0	Nov 25, 2025	AI Assistant	Security, analytics, platform specifics
2.1	Nov 25, 2025	AI Assistant	OCR Scanning, Import/Export, Notifications, Charts
Document maintained by: Product & Engineering Team
For questions: Docs repo: github.com/expensetracker/product-docs
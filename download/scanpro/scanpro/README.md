# ScanPro - Professional Document Scanner

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android" alt="Android">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License">
</p>

ScanPro is a production-ready Android document scanning application built with Flutter, inspired by CamScanner, Adobe Scan, and Microsoft Lens.

## Features

### Scanner Engine
- Camera Scanner with Auto Edge Detection
- Real-Time Edge Detection Overlay
- Auto Capture & Manual Capture
- Batch/Multi-Page Scanning
- Gallery Import

### Document Processing (OpenCV)
- Auto Crop & Smart Crop
- Perspective Correction
- Shadow Removal & Noise Reduction
- Contrast Enhancement & Sharpening
- B&W, Color, Grayscale Modes

### OCR System (Google ML Kit)
- Text Extraction (English, Hindi + more)
- Smart Actions: Phone, Email, URL, Address, Date detection
- Copy, Search, Translate, Export Text

### PDF Tools (Syncfusion)
- Create, Merge, Split, Compress PDFs
- Rearrange, Rotate, Insert, Delete Pages
- PDF Viewer with Annotations

### AI Features (Gemini API)
- Document Summary & Key Point Extraction
- Smart Rename & Auto Categorization
- Tag Generation & Translation
- Invoice/Resume/Receipt Data Extraction

### Cloud Sync (Firebase)
- Login, Registration, Google Sign-In
- Cloud Backup & Multi-Device Sync
- Offline-First with Conflict Resolution

### Security
- App Lock (PIN + Biometric)
- AES-256 File Encryption
- Secure Cloud Storage

### Additional Features
- Digital Signature System
- PDF Annotations (Highlight, Draw, Notes)
- QR & Barcode Scanner
- Global Search across Files & OCR Content

## Tech Stack

| Category | Technology |
|----------|-----------|
| Frontend | Flutter |
| State Management | Riverpod |
| Local Database | Hive |
| Backend | Firebase |
| OCR | Google ML Kit |
| PDF | Syncfusion PDF |
| Image Processing | OpenCV |
| AI | Gemini API |
| Auth | Firebase Auth + local_auth |

## Architecture

Clean Architecture with MVVM pattern:

```
lib/
├── core/           # Theme, Constants, Utils, Widgets
├── di/             # Dependency Injection (Riverpod)
├── features/       # Feature modules
│   ├── home/       # Dashboard
│   ├── scanner/    # Camera + Edge Detection + Processing
│   ├── documents/  # Document Management
│   ├── ocr/        # Text Recognition
│   ├── pdf_tools/  # PDF Operations
│   ├── search/     # Global Search
│   ├── cloud_sync/ # Firebase Sync
│   ├── security/   # Biometric + Encryption
│   ├── ai_features/# Gemini AI
│   ├── signature/  # Digital Signatures
│   ├── annotations/# PDF Annotations
│   ├── qr_scanner/ # QR/Barcode
│   ├── profile/    # User Profile
│   └── settings/   # App Settings
└── main.dart
```

Each feature follows:
```
feature/
├── presentation/   # Pages, Widgets, Providers
├── domain/         # Entities, Use Cases, Repositories
└── data/           # Models, Repository Impls, Services
```

## Getting Started

### Prerequisites
- Flutter 3.22+
- Android Studio / VS Code
- Firebase project (for cloud features)
- Gemini API key (for AI features)

### Setup

```bash
# Clone the repository
git clone https://github.com/scanpro-dev/scanpro.git
cd scanpro

# Install dependencies
flutter pub get

# Generate code (Hive adapters, Freezed, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android app with package name `com.scanpro.app`
3. Download `google-services.json` to `android/app/`
4. Enable Authentication, Firestore, and Storage

### Gemini AI Setup
1. Get API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Add to `lib/core/constants/api_constants.dart`

## Project Stats

- **215 Dart files**
- **32,000+ lines** of production code
- **10 feature modules**
- **56+ unit tests**, **24+ widget tests**, **9 integration tests**
- **Material 3** with dark/light mode

## License

MIT License - see [LICENSE](LICENSE) for details.

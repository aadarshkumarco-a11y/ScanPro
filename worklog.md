# ScanPro Project Worklog

## Project Overview

**Project Name:** ScanPro - Professional Document Scanning App  
**Platform:** Flutter (Android)  
**Architecture:** Clean Architecture with Feature-First Organization  
**State Management:** Riverpod  
**Navigation:** GoRouter  

---

## Task 1: Architecture Document Generation

**Status:** Completed

### Deliverables
- `ScanPro_Architecture_Document.pdf` - Comprehensive architecture document

### Summary
Generated the complete ScanPro Architecture Document covering:
- Application overview and feature specification (Scanner, OCR, PDF Tools, AI Features, Cloud Sync, Security, QR Scanner, Signature, Annotations)
- Clean Architecture layer diagram (Presentation → Domain → Data)
- Feature-first directory structure (`lib/features/{feature}/domain|data|presentation`)
- Technology stack decisions (Flutter, Riverpod, GoRouter, Hive, Firebase, ML Kit, Syncfusion PDF, Gemini AI, OpenCV, local_auth)
- State management strategy with Riverpod StateNotifiers and FutureProviders
- Navigation and routing structure with GoRouter ShellRoute
- Security architecture (PIN lock, biometric auth, AES encryption, flutter_secure_storage)
- Error handling strategy (Either<Failure, T> pattern with dartz)
- Data flow diagrams for each feature module
- API integration patterns (Firebase, Gemini, ML Kit)
- Testing strategy (unit, widget, integration)

---

## Task 2: Core Layer

**Status:** Completed

### Deliverables
- `lib/core/usecases/usecase.dart` - Base UseCase interface with Either return type
- `lib/core/errors/failures.dart` - Failure hierarchy (ScannerFailure, OCRFailure, PDFFailure, SyncFailure, AuthFailure, AIFailure, SecurityFailure, ServerFailure, NetworkFailure, CacheFailure, ValidationFailure, NotFoundFailure)
- `lib/core/errors/exceptions.dart` - Exception hierarchy mirroring failures
- `lib/core/constants/api_constants.dart` - API endpoint constants
- `lib/core/constants/firebase_constants.dart` - Firebase collection/path constants
- `lib/core/constants/app_constants.dart` - App-wide constants (name, version, etc.)
- `lib/core/constants/db_constants.dart` - Hive box name constants
- `lib/core/theme/app_theme.dart` - Light/dark theme builders
- `lib/core/theme/color_schemes.dart` - Material 3 color schemes
- `lib/core/theme/text_styles.dart` - Typography definitions
- `lib/core/theme/dimensions.dart` - Spacing/sizing constants
- `lib/core/extensions/string_extensions.dart` - String utility extensions
- `lib/core/extensions/date_extensions.dart` - Date formatting extensions
- `lib/core/extensions/context_extensions.dart` - BuildContext utility extensions
- `lib/core/utils/image_utils.dart` - Image processing helpers
- `lib/core/utils/file_utils.dart` - File system helpers
- `lib/core/utils/date_utils.dart` - Date manipulation helpers
- `lib/core/utils/validators.dart` - Input validation helpers
- `lib/core/routing/app_router.dart` - GoRouter configuration with ShellRoute, auth guards, and all application routes
- `lib/core/network/network_info.dart` - Network connectivity checker
- `lib/core/network/api_client.dart` - HTTP API client wrapper
- `lib/core/widgets/loading_widget.dart` - Reusable loading indicator
- `lib/core/widgets/custom_app_bar.dart` - Shared app bar component
- `lib/core/widgets/error_widget.dart` - Reusable error display
- `lib/core/widgets/empty_state.dart` - Empty state placeholder widget

### Key Design Decisions
- Used `Either<Failure, T>` from dartz for functional error handling
- Equatable on all Failure/Entity classes for value comparison
- NoParams marker class for parameterless use cases
- ValidationFailure and NotFoundFailure added to support use case input validation
- Created `lib/core/error/` barrel re-exports for backward-compatible imports

---

## Task 3: DI and Routing

**Status:** Completed

### Deliverables
- `lib/di/injection.dart` - Central DI container with Riverpod providers
- `lib/di/modules/scanner_module.dart` - Scanner feature DI module
- `lib/di/modules/ocr_module.dart` - OCR feature DI module
- `lib/di/modules/pdf_module.dart` - PDF tools DI module
- `lib/di/modules/ai_module.dart` - AI features DI module
- `lib/di/modules/security_module.dart` - Security feature DI module with auth/lock state providers
- `lib/di/modules/sync_module.dart` - Cloud sync DI module
- `lib/app.dart` - Root ScanProApp widget with MaterialApp.router, theme mode provider, and GoRouter
- `lib/main.dart` - Entry point with Firebase, Hive, and system UI initialization

### Key Design Decisions
- Module-based DI registration following feature boundaries
- Riverpod Provider-based DI (no code generation required)
- GoRouter with ShellRoute for bottom navigation persistence
- Auth and lock guards in router redirect
- Security module provides `isAppLockedProvider` and `isAuthenticatedProvider` for route guards
- RiverpodListenable bridge for GoRouter refresh on state changes

---

## Task 4: Domain and Data Layers

**Status:** Completed

### Domain Layer Deliverables

**Scanner:**
- Entities: ScanResult, ScanDocument, EdgeDetectionResult
- Repositories: ScannerRepository, ImageProcessingRepository
- Use Cases: CaptureDocument, DetectEdges, CropDocument, EnhanceDocument, ImportFromGallery

**OCR:**
- Entities: OCRResult, TextBlock
- Repository: OCRRepository
- Use Cases: ExtractText, TranslateText, DetectSmartActions

**PDF Tools:**
- Entities: PDFDocument, PDFOperationResult
- Repository: PDFRepository
- Use Cases: CreatePDF, MergePDFs, SplitPDF, CompressPDF

**Documents:**
- Entities: ScanDocument (shared), Folder, Tag, Collection
- Repository: DocumentRepository
- Use Cases: GetDocuments, SearchDocuments, ManageDocument

**AI Features:**
- Entities: AISummary, AIExtraction
- Repository: AIRepository
- Use Cases: SummarizeDocument, SmartRename, ExtractData

**Cloud Sync:**
- Entities: SyncRecord, SyncStatus
- Repository: SyncRepository
- Use Cases: SyncDocuments, ResolveConflict

**Security:**
- Entity: LockConfig
- Repository: SecurityRepository

**Signature:**
- Entity: Signature
- Repository: SignatureRepository

**Annotations:**
- Entity: Annotation
- Repository: AnnotationRepository

### Data Layer Deliverables

**Scanner:**
- ScannerRepositoryImpl, ImageProcessingRepositoryImpl
- Services: CameraService, EdgeDetectionService, ImageProcessingService, PerspectiveCorrectionService
- Models: ScanResultModel, ScanDocumentModel

**OCR:**
- OCRRepositoryImpl
- Services: MLKitService
- Models: OCRResultModel

**PDF Tools:**
- PDFRepositoryImpl
- Services: SyncfusionPDFService
- Models: PDFDocumentModel

**Documents:**
- DocumentRepositoryImpl
- Models: FolderModel, TagModel

**AI Features:**
- AIRepositoryImpl
- Services: GeminiService
- Models: AISummaryModel

**Cloud Sync:**
- SyncRepositoryImpl
- Services: FirebaseSyncService
- Models: SyncRecordModel

**Security:**
- SecurityRepositoryImpl
- Services: BiometricService, EncryptionService
- Models: LockConfigModel

**Signature:**
- SignatureRepositoryImpl
- Models: SignatureModel

**Annotations:**
- AnnotationRepositoryImpl
- Models: AnnotationModel

### Key Design Decisions
- Repository implementations convert Exceptions to Failures using try/catch
- Models extend Entity classes and add fromJson/toJson for serialization
- Service classes handle platform-specific implementations (ML Kit, Syncfusion, etc.)
- ScanDocument entity serves as the central document model across features
- EdgeDetectionResult includes confidence scoring and notDetected factory

---

## Task 5: Scanner & Documents UI

**Status:** Completed

### Scanner UI Deliverables
- `presentation/pages/camera_screen.dart` - Camera viewfinder with capture controls
- `presentation/pages/crop_screen.dart` - Edge point adjustment for manual crop correction
- `presentation/pages/enhance_screen.dart` - Document enhancement filters (auto, sharp, magic, shadows, brighten)
- `presentation/pages/batch_scan_screen.dart` - Multi-page scanning workflow
- `presentation/widgets/capture_button.dart` - Animated scan button
- `presentation/widgets/edge_overlay_painter.dart` - Custom painter for edge visualization
- `presentation/widgets/filter_option_card.dart` - Filter selection cards
- `presentation/widgets/enhancement_slider.dart` - Enhancement intensity slider
- `presentation/widgets/scan_page_thumbnail.dart` - Page preview thumbnails
- `presentation/providers/scanner_provider.dart` - Scanner state management

### Documents UI Deliverables
- `presentation/pages/documents_screen.dart` - Main documents list with grid/list toggle, search, sort/filter
- `presentation/pages/document_detail_screen.dart` - Document detail view with actions
- `presentation/pages/folder_view_screen.dart` - Folder contents view
- `presentation/pages/trash_screen.dart` - Trash/deleted documents
- `presentation/widgets/document_grid_view.dart` - Grid layout for documents
- `presentation/widgets/document_list_view.dart` - List layout for documents
- `presentation/widgets/document_card.dart` - Grid card component
- `presentation/widgets/document_list_tile.dart` - List tile component
- `presentation/widgets/folder_card.dart` - Folder navigation card
- `presentation/widgets/tag_chip.dart` - Tag display chip
- `presentation/widgets/sort_filter_bar.dart` - Sort and filter controls
- `presentation/providers/documents_provider.dart` - Documents state with sort/filter/search, mock data

### Key Design Decisions
- ConsumerWidget/ConsumerStatefulWidget pattern for Riverpod integration
- SortFilterState with DocumentSortField (name, date, size, category) and DocumentFilter (all, pdf, image, ocr, favorites)
- Pull-to-refresh on documents list via RefreshIndicator
- FloatingActionButton for quick scan from documents screen
- flutter_animate for smooth entry animations

---

## Task 6: OCR, PDF, Search, AI UI

**Status:** Completed

### OCR UI Deliverables
- `presentation/pages/ocr_screen.dart` - OCR processing screen
- `presentation/pages/ocr_result_screen.dart` - Extracted text with smart actions
- `presentation/widgets/smart_action_chip.dart` - Tappable phone/email/URL chips
- `presentation/widgets/text_block_widget.dart` - Paragraph text block display
- `presentation/providers/ocr_provider.dart` - OCR state management

### PDF Tools UI Deliverables
- `presentation/pages/pdf_merge_screen.dart` - PDF merge interface
- `presentation/pages/pdf_split_screen.dart` - PDF split with page ranges
- `presentation/pages/pdf_compress_screen.dart` - PDF compression with quality options
- `presentation/pages/pdf_viewer_screen.dart` - PDF reader with annotations
- `presentation/pages/pdf_editor_screen.dart` - PDF page editor (reorder, rotate, delete)
- `presentation/widgets/pdf_thumbnail.dart` - PDF page thumbnail
- `presentation/widgets/quality_option_card.dart` - Compression quality selection
- `presentation/widgets/page_range_input.dart` - Page range input field
- `presentation/providers/pdf_provider.dart` - PDF operations state management

### Search UI Deliverables
- `presentation/pages/search_screen.dart` - Full-text search with category filters
- `presentation/widgets/search_category_chip.dart` - Search filter chips
- `presentation/widgets/search_result_tile.dart` - Search result display
- `presentation/providers/search_provider.dart` - Search state management

### AI Features UI Deliverables
- `presentation/pages/ai_summary_screen.dart` - AI-generated document summary
- `presentation/pages/ai_extract_screen.dart` - Structured data extraction view
- `presentation/widgets/ai_loading_shimmer.dart` - Loading shimmer for AI processing
- `presentation/widgets/key_point_card.dart` - Key point display cards
- `presentation/widgets/tag_suggestion_chip.dart` - AI-suggested tag chips
- `presentation/widgets/extracted_field_row.dart` - Extracted field key-value display
- `presentation/providers/ai_provider.dart` - AI features state management

---

## Task 7: Security, Sync, Signature, QR, Home, Profile, Settings UI

**Status:** Completed

### Security UI Deliverables
- `presentation/pages/lock_screen.dart` - PIN lock screen with number pad and shake animation on wrong PIN
- `presentation/pages/pin_setup_screen.dart` - PIN setup/confirmation flow
- `presentation/pages/biometric_setup_screen.dart` - Biometric auth setup
- `presentation/widgets/pin_dot.dart` - Animated PIN dot indicator
- `presentation/widgets/number_pad.dart` - Numeric keypad with biometric/backspace
- `presentation/providers/security_provider.dart` - LockState, PinState, BiometricState, EncryptionState notifiers

### Cloud Sync UI Deliverables
- `presentation/pages/sync_screen.dart` - Sync dashboard with status
- `presentation/widgets/sync_status_indicator.dart` - Sync status badge
- `presentation/widgets/conflict_resolution_card.dart` - Conflict resolution UI
- `presentation/widgets/storage_usage_bar.dart` - Storage usage visualization
- `presentation/providers/sync_provider.dart` - Sync state management

### Signature UI Deliverables
- `presentation/pages/signature_screen.dart` - Signature list/management
- `presentation/pages/signature_create_screen.dart` - Signature drawing canvas
- `presentation/widgets/signature_canvas.dart` - Touch drawing surface
- `presentation/widgets/signature_card.dart` - Signature preview card
- `presentation/providers/signature_provider.dart` - Signature state management

### QR Scanner UI Deliverables
- `presentation/pages/qr_scanner_screen.dart` - QR/barcode scanner
- `presentation/widgets/scan_overlay.dart` - Camera scan overlay frame
- `presentation/widgets/scan_result_sheet.dart` - Bottom sheet for scan results
- `presentation/providers/qr_provider.dart` - QR scanner state

### Home UI Deliverables
- `presentation/pages/home_screen.dart` - Dashboard with greeting, quick actions, recent docs, favorites, storage info, AI insights
- `presentation/widgets/quick_action_button.dart` - Circular action buttons (Scan, Import, QR, PDF Tools)
- `presentation/widgets/recent_document_card.dart` - Horizontal document cards
- `presentation/widgets/storage_info_card.dart` - Storage usage display
- `presentation/widgets/premium_banner.dart` - Premium feature banner
- `presentation/providers/home_provider.dart` - Home screen state (DocumentInfo, StorageInfoModel, QuickAction models)

### Profile UI Deliverables
- `presentation/pages/profile_screen.dart` - User profile with stats
- `presentation/widgets/profile_header.dart` - Avatar and name display
- `presentation/widgets/stat_card.dart` - Statistic display card
- `presentation/providers/profile_provider.dart` - Profile state management

### Settings UI Deliverables
- `presentation/pages/settings_screen.dart` - Settings list
- `presentation/widgets/settings_tile.dart` - Navigation settings row
- `presentation/widgets/toggle_tile.dart` - Toggle switch row
- `presentation/widgets/settings_section.dart` - Settings group header
- `presentation/providers/settings_provider.dart` - Settings state

### Annotations UI Deliverables
- `presentation/pages/annotations_screen.dart` - Annotation/drawing overlay
- `presentation/widgets/annotation_toolbar.dart` - Drawing tools toolbar
- `presentation/widgets/drawing_canvas.dart` - Touch drawing surface
- `presentation/providers/annotation_provider.dart` - Annotation state

### Core Shared Widget
- `features/core/widgets/bottom_nav_bar.dart` - Bottom navigation bar component

---

## Task 8: Android Configuration

**Status:** Completed

### Deliverables
- `android/app/build.gradle` - App-level Gradle with SDK versions, dependencies, signing config
- `android/build.gradle` - Project-level Gradle with plugin repositories
- `android/settings.gradle` - Gradle settings with plugin management
- `android/gradle.properties` - Gradle properties (R8, AndroidX)
- `android/gradle/wrapper/gradle-wrapper.properties` - Gradle wrapper version
- `android/app/src/main/AndroidManifest.xml` - Manifest with camera, storage, internet, biometric permissions
- `android/app/src/main/kotlin/com/scanpro/app/MainActivity.kt` - Kotlin MainActivity
- `android/app/proguard-rules.pro` - ProGuard/R8 rules for release builds
- `pubspec.yaml` - Flutter dependencies and project configuration
- `analysis_options.yaml` - Dart lint rules

### Key Configuration
- minSdkVersion: 24, targetSdkVersion: 34
- Package name: com.scanpro.app
- Permissions: CAMERA, READ/WRITE_EXTERNAL_STORAGE, INTERNET, USE_BIOMETRIC, VIBRATE, POST_NOTIFICATIONS
- Dependencies include Flutter SDK, Firebase, ML Kit, Syncfusion, camera, OpenCV, Gemini AI, local_auth, etc.
- dev_dependencies include flutter_test, mocktail, integration_test, build_runner

---

## Task 9: Test Files

**Status:** Completed

### Unit Tests (9 files)

1. **`test/unit/scanner/capture_document_test.dart`**
   - Test successful capture returns ScanResult
   - Test edge detection failure returns ScannerFailure (graceful fallback)
   - Test camera permission denied returns ScannerFailure
   - Test auto-detect triggers edge detection when edges are empty
   - Test auto-detect skips edge detection when edges are present
   - Test auto-detect disabled skips edge detection

2. **`test/unit/scanner/detect_edges_test.dart`**
   - Test successful edge detection with valid points
   - Test no document found (notDetected factory)
   - Test low confidence detection (below 0.7 threshold)
   - Test ValidationFailure on empty image path
   - Test ScannerFailure when repository fails

3. **`test/unit/ocr/extract_text_test.dart`**
   - Test successful text extraction with language and confidence
   - Test empty file path returns ValidationFailure
   - Test language detection with smart actions
   - Test OCRFailure when repository fails
   - Test smart actions skipped for empty text

4. **`test/unit/pdf/create_pdf_test.dart`**
   - Test successful PDF creation from images
   - Test empty image list returns ValidationFailure
   - Test PDF with multiple pages
   - Test quality out of range returns ValidationFailure
   - Test PDFFailure when repository fails

5. **`test/unit/pdf/merge_pdfs_test.dart`**
   - Test successful merge with compression metrics
   - Test single PDF returns ValidationFailure
   - Test empty PDF list returns ValidationFailure
   - Test invalid PDF path returns PDFFailure
   - Test merging more than two PDFs

6. **`test/unit/documents/get_documents_test.dart`**
   - Test successful retrieval (excludes archived/deleted by default)
   - Test empty documents list
   - Test exclude archived when includeArchived is false
   - Test include archived when includeArchived is true
   - Test exclude deleted when includeDeleted is false
   - Test filter by folder
   - Test filter by tag
   - Test CacheFailure when repository fails

7. **`test/unit/security/pin_verify_test.dart`**
   - Test correct PIN verification
   - Test incorrect PIN verification
   - Test lockout after max failed attempts (LockConfig.isLockedOut)
   - Test not locked out below max attempts
   - Test reset failed attempts on success
   - Test SecurityFailure when verification fails
   - Test LockConfig.shouldShowLock behaviors

8. **`test/unit/ai/summarize_document_test.dart`**
   - Test successful summary generation with key points and tags
   - Test empty file path returns ValidationFailure
   - Test maxWords <= 0 returns ValidationFailure
   - Test AIFailure when API request fails
   - Test AIFailure rate limit
   - Test AIFailure timeout
   - Test low confidence summary (isHighConfidence = false)

9. **`test/unit/sync/sync_documents_test.dart`**
   - Test successful sync returning SyncRecords
   - Test empty list when nothing to sync
   - Test SyncFailure when network unavailable
   - Test ValidationFailure when batchSize <= 0
   - Test conflict detection (hasConflict)
   - Test failed record retry eligibility (canRetry)
   - Test no retry after max retries
   - Test NetworkFailure when no connectivity

### Widget Tests (3 files)

10. **`test/widget/home_screen_test.dart`**
    - Test renders greeting text ("Good morning!", "What would you like to do today?")
    - Test renders 4 quick action buttons (Scan, Import, QR Code, PDF Tools)
    - Test renders recent documents section with cards
    - Test renders premium banner
    - Test renders storage info card
    - Test renders AI Insights card
    - Test renders favorites section
    - Test renders notification badge
    - Test renders profile avatar

11. **`test/widget/documents_screen_test.dart`**
    - Test renders app bar with "Documents" title
    - Test renders search and view toggle buttons
    - Test renders sort/filter bar
    - Test renders FAB for scanning
    - Test grid/list view toggle
    - Test search field appears on search icon tap
    - Test search field closes on close icon tap
    - Test document list renders after loading

12. **`test/widget/lock_screen_test.dart`**
    - Test renders 6 PIN dots
    - Test renders app title and instructions
    - Test renders number pad with digits 0-9
    - Test renders backspace button
    - Test renders Forgot PIN button
    - Test PIN entry fills dots on digit press
    - Test renders document scanner icon
    - Test error message on incorrect PIN
    - Test PinDot filled/unfilled rendering

### Integration Tests (2 files)

13. **`integration_test/app_test.dart`**
    - Test app launches and renders MaterialApp
    - Test bottom navigation is present
    - Test navigation between Home, Documents, Profile screens
    - Test app theme is applied correctly

14. **`integration_test/scanner_flow_test.dart`**
    - Test scanner page renders
    - Test complete scan workflow (capture → detect edges → enhance)
    - Test crop adjustment modifies edge points
    - Test enhancement filters produce valid paths for all types
    - Test ScanResult.bestImagePath priority (enhanced > cropped > original)

### Bug Fixes Applied During Testing
- Added `ValidationFailure` and `NotFoundFailure` classes to `lib/core/errors/failures.dart` (referenced by use cases but previously missing)
- Created `lib/core/error/` barrel re-exports (`failures.dart`, `exceptions.dart`) to support existing `package:scanpro/core/error/` import paths used throughout the codebase

---

## Project Statistics

- **Total Dart files:** ~150+
- **Features implemented:** 10 (Scanner, OCR, PDF Tools, Documents, AI Features, Cloud Sync, Security, Signature, QR Scanner, Annotations, Search, Home, Profile, Settings)
- **Domain entities:** 12+
- **Use cases:** 16+
- **Repository interfaces:** 8
- **Repository implementations:** 8
- **UI screens:** 25+
- **UI widgets:** 30+
- **DI modules:** 6
- **Unit tests:** 9 files, ~50 test cases
- **Widget tests:** 3 files, ~25 test cases
- **Integration tests:** 2 files, ~8 test cases

---

## Task 2-a: Core Layer Re-creation (scanpro_apk directory)

**Status:** Completed

### Deliverables

1. **`lib/core/constants/app_constants.dart`** - App-wide constants
   - App identity (appName: "ScanPro", version, buildNumber, packageName, description)
   - API key placeholders (Gemini, Firebase keys)
   - Storage keys (secure storage, shared preferences, onboarding, sync, language)
   - Hive box names (documents, folders, tags, sync, signatures, annotations, settings, cache)
   - All route paths and route names for GoRouter navigation
   - Security defaults (PIN length, max attempts, lockout duration, encryption key length, session timeout)
   - Scan defaults (JPEG quality, DPI, edge detection confidence, batch limits, max image size)
   - PDF defaults (compression quality levels, max merge files, default page dimensions)
   - Cloud sync defaults (batch size, max retries, retry delay, conflict timeout, storage limit)
   - OCR defaults (min confidence, max file size, supported languages)
   - AI defaults (summary max words, min confidence, request timeout, max retries)
   - UI / animation durations, border radii, elevations
   - Supported file extensions, date formats, pagination defaults, URLs

2. **`lib/core/theme/app_theme.dart`** - Complete Material 3 theme
   - Primary color: Indigo #4D2DAB, secondary: Teal #00BFA6, accent: #FF6B6B
   - Light and dark theme builders using `ColorScheme.fromSeed`
   - Full component themes: AppBar, Card, ElevatedButton, OutlinedButton, TextButton, FloatingActionButton, BottomNavigationBar, NavigationBar (M3), TextField/InputDecoration, Chip, Dialog, BottomSheet, SnackBar, Divider, Switch, Checkbox, Slider, ProgressIndicator, TabBar, PopupMenu, Tooltip, ListTile, Icon
   - Complete TextTheme with Inter font family (display, headline, title, body, label styles)
   - `AppThemeExtension` on `ThemeData` for semantic colour access (brandPrimary, brandSecondary, brandAccent, brandWarning, brandSuccess, brandInfo)

3. **`lib/core/errors/failures.dart`** - Failure hierarchy with Equatable
   - Abstract `Failure` base class with `message` and optional `code`
   - `ServerFailure` (unexpected, unauthorized, notFound, rateLimited, timeout)
   - `CacheFailure` (notFound, writeError, readError, corrupted)
   - `NetworkFailure` (noConnection, connectionTimeout, serverUnreachable, sslError)
   - `OcrFailure` (noTextDetected, lowConfidence, languageNotSupported, processingError, fileTooLarge)
   - `PdfFailure` (creationError, mergeError, splitError, compressionError, invalidFile, passwordProtected, pageOutOfRange)
   - `SecurityFailure` (incorrectPin, pinLockedOut, biometricNotAvailable, biometricNotEnrolled, biometricFailed, encryptionError, keyNotFound, pinNotSet)
   - `ScannerFailure` (cameraPermissionDenied, cameraError, edgeDetectionFailed, imageProcessingError, noDocumentFound)
   - `SyncFailure` (conflictDetected, uploadFailed, downloadFailed, storageLimitExceeded, authExpired)
   - `AuthFailure` (invalidCredentials, emailAlreadyInUse, weakPassword, tokenExpired, accountDisabled)
   - `AIFailure` (requestFailed, rateLimited, timeout, invalidResponse, quotaExceeded)
   - `ValidationFailure` (emptyField, invalidFormat, outOfRange, tooShort, tooLong)
   - `NotFoundFailure` (document, folder, file, user)

4. **`lib/core/errors/exceptions.dart`** - Exception hierarchy mirroring failures
   - `ServerException` (message, statusCode, responseBody)
   - `CacheException` (message, code)
   - `NetworkException` (message, code, isTimeout, isNoConnection) with factories
   - `OcrException` (message, code, confidence) with factories
   - `PdfException` (message, code, filePath) with factories for invalidFile, passwordProtected, pageOutOfRange
   - `SecurityException` (message, code) with factories for PIN, biometric, encryption errors
   - `ScannerException`, `SyncException`, `AuthException`, `AIException`, `ValidationException`

5. **`lib/core/extensions/context_extensions.dart`** - BuildContext extensions
   - Theme access: theme, colorScheme, textTheme, isDarkMode, isLightMode
   - Media query: width, height, screenSize, shortestSide, longestSide, devicePixelRatio, textScaleFactor
   - Safe area: paddingTop, paddingBottom, viewInsetBottom, isKeyboardVisible, statusBarHeight, navigationBarHeight
   - Responsive breakpoints: isSmallPhone, isPhone, isSmallTablet, isLargeTablet, isLandscape, isPortrait
   - Colour shortcuts: primary, onPrimary, secondary, onSecondary, error, onError, surface, onSurface, background, onBackground
   - Semantic colours: brandPrimary, brandSecondary, brandAccent, warningColor, successColor, infoColor
   - Theme helpers: dividerColor, hintColor, cardColor, inputFillColor
   - Navigation: pop(), canPop
   - Keyboard: hideKeyboard()
   - SnackBar: showSnackBar(), showErrorSnackBar(), showSuccessSnackBar()

6. **`lib/core/utils/validators.dart`** - Input validators (return null for valid, error string for invalid)
   - `email()` - RFC-5322-ish regex validation
   - `password()` - Configurable complexity (minLength, uppercase, lowercase, digit, specialChar)
   - `confirmPassword()` - Password match check
   - `phone()` - 7-15 digit range validation
   - `name()` - Letter/space/hyphen/apostrophe with length bounds
   - `pin()` - Numeric PIN with trivial-PIN detection (sequential, repeated digits)
   - `fileName()` - Illegal character check, reserved name check, leading/trailing space/period check
   - `folderName()` - File system safe validation
   - `required()` - Generic non-empty validator
   - `url()` - http/https URL validation
   - `positiveInt()`, `numberRange()` - Numeric validators

7. **`lib/core/utils/date_formatter.dart`** - Date formatting utilities
   - Pre-configured formatters (display, file, sync, short, monthYear, dayMonthYear, full)
   - `relativeTime()` - "Just now", "5 min ago", "Yesterday", "3 days ago", fallback to absolute
   - `smartRelative()` - Today→time, Yesterday, This week→day name, Older→date
   - `documentDate()` - Hybrid relative/absolute for document cards
   - `generateFileName()` - ScanPro_2025-01-15_14-30-00.pdf format
   - Parsing: `tryParse()`, `parseOr()`
   - Utility: `isSameDay()`, `isToday()`, `isYesterday()`, `startOfDay()`, `endOfDay()`, `startOfMonth()`, `endOfMonth()`, `daysBetween()`, `formatDuration()`

8. **`lib/core/utils/file_utils.dart`** - File utilities
   - Size formatting: `formatBytes()` (e.g. "1.46 MB"), `fileSizeShort()`, `getFileSizeString()`, `getFileSize()`
   - Extension handling: `getExtension()`, `getExtensionWithDot()`, `getBaseName()`, `getFileName()`
   - MIME type: `getMimeType()`, `getMimeTypeFromPath()` with comprehensive map (images, documents, audio, video, archives)
   - File category: `FileCategory` enum and `getCategory()`, `getCategoryFromPath()`
   - Type checks: `isImage()`, `isPdf()`, `isDocument()`, `isSupportedForOcr()`
   - Sanitisation: `sanitizeFileName()`, `makeUniqueFileName()`
   - Storage helpers: `storageUsagePercentage()`, `storageUsageRatio()`

9. **`lib/core/widgets/loading_widget.dart`** - Loading widget with shimmer
   - `LoadingWidget.inline()` - Centered spinner with optional message
   - `LoadingWidget.overlay()` - Full-screen modal spinner
   - `LoadingWidget.shimmer()` - Animated gradient sweep wrapper
   - Pre-built skeletons: `ShimmerListTile`, `ShimmerGridCard`, `ShimmerListPage`, `ShimmerGridPage`
   - Custom `_ShimmerBox` helper with configurable size, fraction, border radius, shape

10. **`lib/core/widgets/error_widget.dart`** - Custom error widget with retry
    - `AppErrorWidget` - Full layout (icon, title, message, retry button) and compact layout (inline card)
    - `NetworkErrorWidget` - WiFi-off icon, "No Internet Connection"
    - `ServerErrorWidget` - Cloud-off icon, "Server Error"
    - `PermissionErrorWidget` - Lock icon, configurable permission name
    - `StorageErrorWidget` - Folder-off icon, "Storage Full"

11. **`lib/core/widgets/empty_state_widget.dart`** - Empty state with action button
    - `EmptyStateWidget` - Icon in circular background, title, subtitle, optional CTA button
    - Pre-configured states: `EmptyDocumentsState`, `EmptySearchState`, `EmptyOcrState`, `EmptySyncState`, `EmptyTrashState`, `EmptySignatureState`, `EmptyFolderState`, `EmptyQrHistoryState`

12. **`lib/core/widgets/custom_app_bar.dart`** - Custom app bar
    - `CustomAppBar` - Standard mode (title, subtitle, back button, actions, bottom)
    - `CustomAppBar.search()` - Search mode with embedded TextField, clear button
    - `CustomSliverAppBar` - Sliver equivalent for CustomScrollView
    - Configurable: centerTitle, showBackButton, onBack, backgroundColor, foregroundColor, elevation

13. **`lib/core/routing/app_router.dart`** - GoRouter configuration
    - `AppRoutes` and `AppRouteNames` constants for all routes
    - `appRouterProvider` - Riverpod Provider<GoRouter>
    - `StatefulShellRoute.indexedStack` with 5 tabs: Home, Documents, Scanner, Profile, Settings
    - Full-screen routes: splash, scanner/result, documents/detail, documents/folder, ocr, ocr/result
    - Nested routes: pdf-tools/{create,merge,split,compress}, security/{setup,verify}, ai-features/summary, signature/draw
    - Standalone routes: search, cloud-sync, annotations, qr-scanner
    - Custom transitions: slide-up, fade-in
    - Route guard redirect logic (placeholder for security module)
    - `_ShellScaffold` with NavigationBar (M3)
    - `_PlaceholderScreen` and `_NotFoundScreen` for development

14. **`lib/di/app_module.dart`** - Main Riverpod DI module
    - Core infrastructure: `sharedPreferencesProvider`, `secureStorageProvider`, `appDirProvider`, `tempDirProvider`, `connectivityProvider`, `connectivityStreamProvider`, `isOnlineProvider`
    - Hive boxes: `documentsBoxProvider`, `foldersBoxProvider`, `tagsBoxProvider`, `syncRecordsBoxProvider`, `signaturesBoxProvider`, `settingsBoxProvider`, `cacheBoxProvider`
    - Theme: `ThemeModeNotifier` with persistence, `themeModeProvider`
    - App state: `onboardingCompleteProvider`, `isFirstLaunchProvider`
    - Security: `isAppLockedProvider`, `isPinSetUpProvider`, `isAuthenticatedProvider`
    - Feature placeholders: scanner, OCR, PDF, AI, sync, document sort/filter
    - `SortFilterState` with `SortFilterNotifier` for document list management
    - `initializeApp()` helper for main() setup (SharedPreferences, directories, Hive boxes, ProviderContainer with overrides)

### Additional Changes
- Updated `pubspec.yaml` with full dependency list (flutter_riverpod, go_router, dartz, equatable, shimmer, hive, connectivity_plus, etc.)
- Updated `lib/main.dart` to use `initializeApp()`, `UncontrolledProviderScope`, `ScanProApp` ConsumerWidget with MaterialApp.router

### Key Design Decisions
- Primary colour Indigo #4D2DAB used throughout theme and extensions
- Material 3 with `useMaterial3: true` and `ColorScheme.fromSeed`
- Equatable on all Failure classes for Riverpod state comparison
- All validators follow Flutter's `TextFormField.validator` convention (null = valid)
- GoRouter with `StatefulShellRoute.indexedStack` for persistent bottom navigation
- Riverpod providers with override pattern for testability and async initialization

---

## Task 2-b: Scanner & Documents Feature Implementation (scanpro_apk directory)

**Status:** Completed

### Deliverables – 33 Dart files

#### Scanner Feature (lib/features/scanner/)

**Domain Layer (5 files)**
1. **`domain/entities/scanned_document.dart`** - ScannedDocument entity (id, filePath, thumbnailPath, pages, createdAt, updatedAt, name, tags, isFavorite, folderId, fileSize, ocrText, pdfPath, isSynced, isLocked) and ScannedPage entity (id, filePath, cropArea, rotation, brightness, contrast, filters), both with Equatable and copyWith
2. **`domain/repositories/scanner_repository.dart`** - Abstract ScannerRepository with: scanDocument(), cropImage(), enhanceImage(), rotateImage(), applyFilter(), saveDocument(), deleteDocument(), getDocuments(), getDocumentById(), batchScan()
3. **`domain/usecases/scan_document_usecase.dart`** - ScanDocumentUseCase invoking repository.scanDocument()
4. **`domain/usecases/crop_image_usecase.dart`** - CropImageUseCase with cropArea validation (4 doubles, 0.0–1.0 range, left<right, top<bottom)
5. **`domain/usecases/enhance_image_usecase.dart`** - EnhanceImageUseCase with filePath validation
6. **`domain/usecases/batch_scan_usecase.dart`** - BatchScanUseCase with pageCount range validation (1–AppConstants.maxBatchScanPages)

**Data Layer (3 files)**
7. **`data/models/scanned_document_model.dart`** - ScannedPageModel and ScannedDocumentModel with fromEntity(), toEntity(), fromJson(), toJson(), fromHive() (handles JSON-encoded pages string in Hive)
8. **`data/datasources/scanner_local_datasource.dart`** - ScannerLocalDatasource using Hive Box for CRUD; saveDocument (generates UUID), getDocuments (sorted by updatedAt desc), getDocumentById, deleteDocument (cleans up files on disk), generateScanFileName(), getScanDirectory()
9. **`data/repositories/scanner_repository_impl.dart`** - ScannerRepositoryImpl with image processing via `image` package: crop (img.copyCrop), enhance (img.adjustColor), rotate (img.copyRotate), filters (grayscale, bw, magic_color, brightened), all with file persistence via localDatasource

**Presentation Layer (5 files)**
10. **`presentation/providers/scanner_provider.dart`** - Riverpod providers: scannerRepositoryProvider, scanDocumentUseCaseProvider, cropImageUseCaseProvider, enhanceImageUseCaseProvider, batchScanUseCaseProvider; ScannerState (status, currentDocument, documents, isFlashOn, isBatchMode, batchPageCount, selectedFilter, cropArea); ScannerNotifier with scanDocument, cropImage, enhanceImage, applyFilter, rotateImage, batchScan, saveDocument, discardScan, toggleFlash, toggleBatchMode, loadDocuments, reset; Derived providers: scanOperationStatusProvider, selectedFilterProvider, isFlashOnProvider, isBatchModeProvider
11. **`presentation/screens/scanner_screen.dart`** - Full-screen scanner with dark background, AppBar with close button and batch indicator, camera preview placeholder, viewfinder overlay with corner markers, scanning indicator, ScannerControls widget, error banner, navigation to ScanResultScreen on success
12. **`presentation/screens/scan_result_screen.dart`** - Scan result with image preview, crop mode toggle with CropOverlay, edit tools (rotate left/right, flip, enhance), FilterSelector with 5 options (Original, Grayscale, B&W, Magic Color, Brightened), Save/Discard action buttons, no-document placeholder
13. **`presentation/widgets/scanner_controls.dart`** - Camera controls overlay with gradient background; _ControlButton (gallery, flash), _CaptureButton (ring design with primary/secondary colour), batch mode toggle chip
14. **`presentation/widgets/filter_selector.dart`** - FilterOption data class, horizontal scrollable FilterSelector with _FilterChip (animated selection, icon circle, label)
15. **`presentation/widgets/crop_overlay.dart`** - CropOverlay with 4 draggable corner handles, _CropMaskPainter (translucent outside), _CropBorderPainter (white border), _CropGridPainter (rule-of-thirds lines); emits normalised cropArea onPanEnd

#### Documents Feature (lib/features/documents/)

**Domain Layer (8 files)**
16. **`domain/entities/document_folder.dart`** - DocumentFolder entity (id, name, createdAt, color, icon, parentFolderId, documentCount, isSynced) with Equatable and copyWith
17. **`domain/entities/document_tag.dart`** - DocumentTag entity (id, name, color, usageCount, createdAt) with Equatable and copyWith
18. **`domain/repositories/document_repository.dart`** - Abstract DocumentRepository with: getDocuments, getDocumentById, moveToTrash, restoreFromTrash, permanentDelete, emptyTrash, getTrashedDocuments, toggleFavorite, getFavoriteDocuments, moveDocumentToFolder, addTagToDocument, removeTagFromDocument, renameDocument, getFolders, createFolder, renameFolder, deleteFolder, getTags, createTag, deleteTag
19. **`domain/usecases/get_documents_usecase.dart`** - GetDocumentsUseCase with folderId, tag, includeDeleted filters
20. **`domain/usecases/manage_folders_usecase.dart`** - ManageFoldersUseCase with createFolder, renameFolder, deleteFolder (name/folderId validation)
21. **`domain/usecases/manage_tags_usecase.dart`** - ManageTagsUseCase with addTagToDocument, removeTagFromDocument, createTag, deleteTag (validation on empty fields)
22. **`domain/usecases/favorite_document_usecase.dart`** - FavoriteDocumentUseCase with toggleFavorite and getFavorites
23. **`domain/usecases/trash_usecase.dart`** - TrashUseCase with moveToTrash, restore, permanentDelete, emptyTrash, getTrashedDocuments

**Data Layer (4 files)**
24. **`data/models/document_folder_model.dart`** - DocumentFolderModel with fromEntity, toEntity, fromJson, toJson, fromHive (handles String/int createdAt)
25. **`data/models/document_tag_model.dart`** - DocumentTagModel with fromEntity, toEntity, fromJson, toJson, fromHive
26. **`data/datasources/document_local_datasource.dart`** - DocumentLocalDatasource using 3 Hive boxes (documents, folders, tags); soft-delete via isTrashed flag; CRUD for all three entity types; date parsing helper
27. **`data/repositories/document_repository_impl.dart`** - DocumentRepositoryImpl implementing all 21 repository methods, converting CacheException → CacheFailure/NotFoundFailure

**Presentation Layer (6 files)**
28. **`presentation/providers/document_provider.dart`** - Riverpod providers: documentRepositoryProvider, 5 use case providers; DocumentsState (status, documents, favoriteDocuments, trashedDocuments, folders, tags, errorMessage, selectedFolderId, selectedTag); DocumentsNotifier with full CRUD for documents, folders, tags, trash, favourites; Derived providers: documentsListProvider, foldersProvider, tagsProvider, favoriteDocumentsProvider, trashedDocumentsProvider
29. **`presentation/screens/documents_screen.dart`** - Documents list/grid with AppBar search toggle, view toggle, sort popup; folder row (FolderChip), tag filter row (ChoiceChip); CustomScrollView with SliverGrid/SliverList; sort/filter logic (name, date, size, category × ascending/descending; all, pdf, image, ocr, favorites); FAB "Scan" button; RefreshIndicator
30. **`presentation/screens/document_detail_screen.dart`** - Document detail with image preview, details card (created, modified, size, pages, synced), tags section, OCR text preview with "View Full" link, quick actions (Share, PDF), popup menu (Rename, Move, OCR, PDF, Share, Delete); rename dialog, move-to-folder dialog, delete confirmation
31. **`presentation/screens/folder_screen.dart`** - Folder contents with grid/list toggle, rename/delete folder from AppBar popup; EmptyFolderState fallback
32. **`presentation/widgets/document_card.dart`** - Dual-mode (grid/list) DocumentCard with thumbnail, name, date, size, favourite badge, page count badge, popup menu (favourite, delete)
33. **`presentation/widgets/folder_chip.dart`** - FolderChip with animated selection, folder colour/icon parsing, document count badge

### Key Design Decisions
- Primary colour Indigo #4D2DAB consistently used across all screens and widgets
- Clean Architecture strictly followed: domain → data → presentation
- All entities use Equatable; all models have fromJson/toJson/fromHive/toEntity/fromEntity
- Riverpod StateNotifier pattern for both ScannerNotifier and DocumentsNotifier
- ScannerRepositoryImpl uses `image` package for real image processing (crop, rotate, filter, enhance)
- DocumentLocalDatasource implements soft-delete via `isTrashed` flag in the Hive documents box
- Scanner controls use dark gradient overlay matching camera UI conventions
- Crop overlay uses CustomPainter for mask, border, and rule-of-thirds grid
- Documents screen integrates with existing SortFilterState/SortFilterNotifier from app_module.dart
- All screens use Material 3 Scaffold with AppBar and body

---

## Task 2-c: OCR & PDF Tools Feature Implementation (scanpro_apk directory)

**Status:** Completed

### Deliverables – 30 Dart files

#### OCR Feature (lib/features/ocr/)

**Domain Layer (4 files)**
1. **`domain/entities/ocr_result.dart`** - OcrResult entity (id, documentId, text, blocks, language, confidence, createdAt) and TextBlock entity (text, boundingBox, confidence, blockType), both with Equatable and copyWith; computed properties: isHighConfidence, wordCount, characterCount
2. **`domain/repositories/ocr_repository.dart`** - Abstract OcrRepository with: recognizeText(), recognizeTextFromPath(), getOcrResults(), getOcrResultByDocumentId(), deleteOcrResult(), extractTextRegions()
3. **`domain/usecases/recognize_text_usecase.dart`** - RecognizeTextUseCase with imagePath validation (empty check), delegates to OcrRepository.recognizeText()
4. **`domain/usecases/extract_text_regions_usecase.dart`** - ExtractTextRegionsUseCase with imagePath validation, delegates to OcrRepository.extractTextRegions()

**Data Layer (4 files)**
5. **`data/models/ocr_result_model.dart`** - TextBlockModel and OcrResultModel with fromEntity(), toEntity(), fromJson(), toJson(), fromHive() (handles JSON-encoded blocks string in Hive, String/int createdAt)
6. **`data/datasources/ocr_local_datasource.dart`** - OcrLocalDatasource using Hive cacheBox with `ocr_` key prefix for CRUD; saveOcrResult (generates UUID), getOcrResults (sorted by createdAt desc), getOcrResultById, getOcrResultByDocumentId, deleteOcrResult
7. **`data/datasources/ocr_ml_datasource.dart`** - OcrMlDatasource wrapping google_mlkit_text_recognition TextRecognizer; recognizeText() processes InputImage from file path, extracts blocks with bounding boxes and confidence; extractTextRegions() provides finer-grained paragraph+line block extraction; dispose() closes native resources
8. **`data/repositories/ocr_repository_impl.dart`** - OcrRepositoryImpl delegates to OcrMlDatasource for recognition and OcrLocalDatasource for persistence; converts OcrException → OcrFailure, CacheException → CacheFailure

**Presentation Layer (4 files)**
9. **`presentation/providers/ocr_provider.dart`** - Riverpod providers: ocrRepositoryProvider, recognizeTextUseCaseProvider, extractTextRegionsUseCaseProvider; OcrStatus enum (idle, loading, recognizing, extracting, success, error); OcrState (status, currentResult, results, errorMessage, selectedLanguage, selectedDocumentPath, selectedDocumentId, progress); OcrNotifier with selectDocument, setLanguage, recognizeText, extractTextRegions, loadResults, deleteResult, reset, clearCurrentResult; Derived providers: ocrStatusProvider, currentOcrResultProvider, ocrProgressProvider
10. **`presentation/screens/ocr_screen.dart`** - OCR screen with header illustration, document selection card (tap opens bottom sheet with gallery/scanner/recent options), language picker (12 languages with ChoiceChips), progress indicator with percentage, start OCR and extract regions buttons, recent results list with delete capability; _DocumentSelectionCard, _LanguagePicker, _ProgressSection, _OcrResultTile, _DocumentPickerSheet, _PickerOption helper widgets
11. **`presentation/screens/ocr_result_screen.dart`** - OCR result with info bar (language, confidence, words, blocks), text blocks with TextBlockHighlight, full text section with SelectableText, search within text with TextField in AppBar, edit mode toggle with warning banner, copy all/share actions via popup menu and bottom bar; _ResultInfoBar, _InfoChip, _BottomActionBar helper widgets
12. **`presentation/widgets/text_block_highlight.dart`** - TextBlockHighlight widget showing block type badge, confidence indicator with color coding (green ≥0.8, orange ≥0.6, red <0.6), bounding box position info, text content with optional search query highlighting via RichText/TextSpan

#### PDF Tools Feature (lib/features/pdf_tools/)

**Domain Layer (7 files)**
13. **`domain/entities/pdf_document.dart`** - PdfDocument entity (id, filePath, fileName, pageCount, fileSize, createdAt, isEncrypted, metadata) and PdfDocumentMetadata entity (title, author, subject, keywords, creator, producer, creationDate, modificationDate), both with Equatable and copyWith; fileSizeFormatted computed property
14. **`domain/entities/pdf_operation.dart`** - PdfOperation enum (merge, split, compress, create, watermark, password) with displayName, description, iconCode getters; PdfOperationResult entity (id, operation, outputPath, success, originalSize, resultSize, pageCount, errorMessage, completedAt) with compressionRatio, compressionPercentage, formatted size computed properties
15. **`domain/repositories/pdf_repository.dart`** - Abstract PdfRepository with: createPdf(), mergePdfs(), splitPdf(), compressPdf(), addWatermark(), protectPdf(), getPdfInfo()
16. **`domain/usecases/create_pdf_usecase.dart`** - CreatePdfUseCase with imagePaths empty validation
17. **`domain/usecases/merge_pdf_usecase.dart`** - MergePdfUseCase with <2 PDFs validation and max merge limit (AppConstants.pdfMaxMergeFiles)
18. **`domain/usecases/split_pdf_usecase.dart`** - SplitPdfUseCase with empty path and empty page ranges validation
19. **`domain/usecases/compress_pdf_usecase.dart`** - CompressPdfUseCase with empty path and quality range (0.0–1.0) validation

**Data Layer (3 files)**
20. **`data/models/pdf_document_model.dart`** - PdfDocumentMetadataModel, PdfDocumentModel, and PdfOperationResultModel with fromEntity(), toEntity(), fromJson(), toJson(), fromHive() (handles JSON-encoded metadata string in Hive, String/int dates, PdfOperation enum name serialization)
21. **`data/datasources/pdf_local_datasource.dart`** - PdfLocalDatasource using Hive cacheBox with `pdf_doc_` and `pdf_op_` key prefixes; CRUD for PdfDocuments and OperationResults; getPdfDirectory() and generatePdfFileName() static helpers; file cleanup on delete
22. **`data/repositories/pdf_repository_impl.dart`** - PdfRepositoryImpl using syncfusion_flutter_pdf; createPdf (PdfDocument + PdfBitmap per page, fit to A4), mergePdfs (template-based page appending), splitPdf (parsePageRange helper, template extraction per range), compressPdf (quality → PdfCompressionLevel mapping), addWatermark (rotated -45° text with PdfStandardFont), protectPdf (userPassword + ownerPassword + permissions), getPdfInfo (page count, encryption check, document information extraction)

**Presentation Layer (8 files)**
23. **`presentation/providers/pdf_provider.dart`** - Riverpod providers: pdfRepositoryProvider, createPdfUseCaseProvider, mergePdfUseCaseProvider, splitPdfUseCaseProvider, compressPdfUseCaseProvider; PdfStatus enum (idle, loading, creating, merging, splitting, compressing, watermarking, protecting, success, error); PdfState with all operation-specific fields (selectedImagePaths, selectedPdfPaths, splitPdfPath, pageRanges, compressPdfPath, compressionQuality, watermarkPdfPath, watermarkText, protectPdfPath, protectPassword); PdfNotifier with addImage, removeImage, reorderImages, createPdf, addPdfForMerge, removePdfForMerge, reorderPdfsForMerge, mergePdfs, setSplitPdfPath, addPageRange, removePageRange, splitPdf, setCompressPdfPath, setCompressionQuality, compressPdf, reset, clearError
24. **`presentation/screens/pdf_tools_screen.dart`** - PDF Tools hub with header illustration, 2-column GridView of PdfToolCard widgets (Create, Merge, Split, Compress, Watermark, Protect), each with themed color; Pro Tips section with gradient background
25. **`presentation/screens/create_pdf_screen.dart`** - Create PDF from images with file name input, add images button, reorderable ReorderableListView with drag handle and delete per image, create button with page count, progress indicator, success banner with file info
26. **`presentation/screens/merge_pdf_screen.dart`** - Merge PDFs with output file name input, add PDF button, info banner, reorderable list with position numbers, merge button with count, progress indicator, success banner with page count and size
27. **`presentation/screens/split_pdf_screen.dart`** - Split PDF with PDF selection card, PageRangeSelector widget, output preview showing file names per range, progress indicator, success banner, split button
28. **`presentation/screens/compress_pdf_screen.dart`** - Compress PDF with header, PDF selection card, three quality option cards (Low/Medium/High with AppConstants quality values), progress indicator, compression result card with before/after size and percentage reduction
29. **`presentation/widgets/pdf_tool_card.dart`** - PdfToolCard with themed icon circle, title, description, arrow indicator; configurable color per tool
30. **`presentation/widgets/page_range_selector.dart`** - PageRangeSelector with text input + add button, quick-add chips (1-1, 1-3, Odd pages), validation (regex for single page and range, start ≤ end, pages ≥ 1), scrollable list of added ranges with page count descriptions and delete buttons

### Key Design Decisions
- OCR ML Kit datasource uses `TextRecognizer(script: TextRecognitionScript.latin)` with `processImage()` for both recognizeText and extractTextRegions
- OCR local datasource uses `ocr_` key prefix in the shared cache Hive box to avoid collisions
- OCR confidence color coding: green ≥0.8, orange ≥0.6, red <0.6
- PDF repository uses Syncfusion `PdfDocument` API with template-based page operations for merge/split
- PDF compression maps quality 0.0–1.0 to Syncfusion PdfCompressionLevel (best/normal/belowNormal/noCompression)
- PDF watermark renders at -45° rotation with Helvetica font and semi-transparent grey brush
- PDF local datasource uses `pdf_doc_` and `pdf_op_` key prefixes in the shared cache Hive box
- All models handle both String and int date formats in fromHive() for Hive compatibility
- All entities use Equatable; all models extend entities and provide fromJson/toJson/fromHive/toEntity
- All screens use Material 3 with Indigo #4D2DAB primary color throughout
- OCR screen provides document picker via DraggableScrollableSheet bottom sheet
- PDF tools hub uses 2-column grid with color-coded cards per tool type
- Create PDF and Merge PDF screens use ReorderableListView for drag-and-drop page/file ordering
- Compress PDF screen uses three quality cards with visual selection indicator
- Page range selector includes input validation and quick-add chips for common ranges

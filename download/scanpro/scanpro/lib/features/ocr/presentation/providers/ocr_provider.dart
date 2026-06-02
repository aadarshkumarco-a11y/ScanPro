import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// ── Domain Models ──────────────────────────────────────────────

class OcrResult {
  final String id;
  final String documentId;
  final String extractedText;
  final double confidence;
  final String language;
  final List<TextBlock> textBlocks;
  final List<SmartAction> smartActions;
  final DateTime processedAt;

  const OcrResult({
    required this.id,
    required this.documentId,
    required this.extractedText,
    required this.confidence,
    required this.language,
    required this.textBlocks,
    required this.smartActions,
    required this.processedAt,
  });

  OcrResult copyWith({
    String? extractedText,
    double? confidence,
    List<SmartAction>? smartActions,
  }) =>
      OcrResult(
        id: id,
        documentId: documentId,
        extractedText: extractedText ?? this.extractedText,
        confidence: confidence ?? this.confidence,
        language: language,
        textBlocks: textBlocks,
        smartActions: smartActions ?? this.smartActions,
        processedAt: processedAt,
      );
}

class TextBlock {
  final String text;
  final Rect boundingBox;
  final double confidence;

  const TextBlock({
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });
}

enum SmartActionType { phone, email, url, address, date }

class SmartAction {
  final SmartActionType type;
  final String value;
  final String label;

  const SmartAction({
    required this.type,
    required this.value,
    required this.label,
  });
}

class OcrTranslation {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;

  const OcrTranslation({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
  });
}

// ── State ──────────────────────────────────────────────────────

class OcrProcessingState {
  final bool isProcessing;
  final double progress;
  final String? documentId;
  final String? error;

  const OcrProcessingState({
    this.isProcessing = false,
    this.progress = 0.0,
    this.documentId,
    this.error,
  });

  OcrProcessingState copyWith({
    bool? isProcessing,
    double? progress,
    String? documentId,
    String? error,
  }) =>
      OcrProcessingState(
        isProcessing: isProcessing ?? this.isProcessing,
        progress: progress ?? this.progress,
        documentId: documentId ?? this.documentId,
        error: error,
      );
}

// ── Notifiers ──────────────────────────────────────────────────

class OcrProcessingNotifier extends StateNotifier<OcrProcessingState> {
  OcrProcessingNotifier() : super(const OcrProcessingState());

  Future<OcrResult?> processDocument(String documentPath, {String language = 'eng'}) async {
    state = OcrProcessingState(isProcessing: true, progress: 0.0, documentId: documentPath);

    try {
      // Simulate OCR processing with progress steps
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        state = state.copyWith(progress: i / 10);
      }

      final result = OcrResult(
        id: const Uuid().v4(),
        documentId: documentPath,
        extractedText: _mockExtractedText(),
        confidence: 0.95,
        language: language,
        textBlocks: _mockTextBlocks(),
        smartActions: _detectSmartActions(_mockExtractedText()),
        processedAt: DateTime.now(),
      );

      // Save to history
      _history.add(result);

      state = const OcrProcessingState(isProcessing: false, progress: 1.0);
      return result;
    } catch (e) {
      state = OcrProcessingState(isProcessing: false, error: e.toString());
      return null;
    }
  }

  void reset() => state = const OcrProcessingState();

  final List<OcrResult> _history = [];

  String _mockExtractedText() =>
      'Invoice #INV-2024-0892\n\n'
      'From: Acme Corporation\n'
      'Date: March 4, 2025\n'
      'Contact: +1 (555) 234-5678\n'
      'Email: billing@acmecorp.com\n'
      'Website: https://www.acmecorp.com\n'
      'Address: 1234 Innovation Drive, San Francisco, CA 94107\n\n'
      'Item\t\tQty\tPrice\n'
      'Cloud Storage Plan\t2\t$49.99\n'
      'Support Package\t1\t$29.99\n\n'
      'Total: $129.97\n'
      'Tax: $10.40\n'
      'Grand Total: $140.37';

  List<TextBlock> _mockTextBlocks() => [
        const TextBlock(text: 'Invoice #INV-2024-0892', boundingBox: Rect.fromLTWH(20, 10, 200, 30), confidence: 0.98),
        const TextBlock(text: 'From: Acme Corporation', boundingBox: Rect.fromLTWH(20, 50, 180, 25), confidence: 0.96),
        const TextBlock(text: 'Date: March 4, 2025', boundingBox: Rect.fromLTWH(20, 80, 160, 25), confidence: 0.97),
      ];

  List<SmartAction> _detectSmartActions(String text) {
    final actions = <SmartAction>[];

    final phoneRegex = RegExp(r'[\+]?[(]?[0-9]{1,4}[)]?[-\s\./0-9]{7,}');
    for (final match in phoneRegex.allMatches(text)) {
      actions.add(SmartAction(type: SmartActionType.phone, value: match.group(0)!, label: 'Call ${match.group(0)}'));
    }

    final emailRegex = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
    for (final match in emailRegex.allMatches(text)) {
      actions.add(SmartAction(type: SmartActionType.email, value: match.group(0)!, label: match.group(0)!));
    }

    final urlRegex = RegExp(r'https?://[\w\.-]+\.\w+[/\w\.-]*');
    for (final match in urlRegex.allMatches(text)) {
      actions.add(SmartAction(type: SmartActionType.url, value: match.group(0)!, label: match.group(0)!));
    }

    final addressRegex = RegExp(r'\d+\s+[\w\s]+(?:Street|St|Avenue|Ave|Drive|Dr|Boulevard|Blvd|Road|Rd|Lane|Ln)[\w\s,]*\d{5}');
    for (final match in addressRegex.allMatches(text)) {
      actions.add(SmartAction(type: SmartActionType.address, value: match.group(0)!, label: match.group(0)!));
    }

    final dateRegex = RegExp(r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4}\b');
    for (final match in dateRegex.allMatches(text)) {
      actions.add(SmartAction(type: SmartActionType.date, value: match.group(0)!, label: match.group(0)!));
    }

    return actions;
  }
}

// ── Providers ──────────────────────────────────────────────────

final ocrProcessingProvider = StateNotifierProvider<OcrProcessingNotifier, OcrProcessingState>(
  (ref) => OcrProcessingNotifier(),
);

final ocrResultProvider = StateProvider<OcrResult?>((ref) => null);

final ocrHistoryProvider = StateProvider<List<OcrResult>>((ref) => []);

final ocrSmartActionsProvider = Provider<List<SmartAction>>((ref) {
  final result = ref.watch(ocrResultProvider);
  if (result == null) return [];
  return result.smartActions;
});

final ocrTranslationProvider = StateNotifierProvider<OcrTranslationNotifier, AsyncValue<OcrTranslation>>((ref) {
  return OcrTranslationNotifier();
});

class OcrTranslationNotifier extends StateNotifier<AsyncValue<OcrTranslation>> {
  OcrTranslationNotifier() : super(const AsyncValue.data(OcrTranslation(
    originalText: '',
    translatedText: '',
    sourceLanguage: '',
    targetLanguage: '',
  )));

  Future<void> translate(String text, String sourceLang, String targetLang) async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      final translated = OcrTranslation(
        originalText: text,
        translatedText: _mockTranslate(text, targetLang),
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
      state = AsyncValue.data(translated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String _mockTranslate(String text, String targetLang) {
    final translations = {
      'hin': 'भुगतान विवरण #INV-2024-0892\nसे: एक्मे कॉर्पोरेशन\nतारीख: 4 मार्च, 2025\nकुल: $140.37',
      'spa': 'Factura #INV-2024-0892\nDe: Acme Corporation\nFecha: 4 de marzo de 2025\nTotal: $140.37',
      'fra': 'Facture #INV-2024-0892\nDe : Acme Corporation\nDate : 4 mars 2025\nTotal : 140,37 $',
      'deu': 'Rechnung #INV-2024-0892\nVon: Acme Corporation\nDatum: 4. März 2025\nGesamt: 140,37 $',
      'jpn': '請求書 #INV-2024-0892\n差出人: Acme Corporation\n日付: 2025年3月4日\n合計: $140.37',
    };
    return translations[targetLang] ?? text;
  }
}

final ocrSelectedLanguageProvider = StateProvider<String>((ref) => 'eng');

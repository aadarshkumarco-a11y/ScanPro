import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Domain Models ──────────────────────────────────────────────

class AiSummary {
  final String documentId;
  final String summaryText;
  final List<String> keyPoints;
  final String suggestedCategory;
  final List<String> suggestedTags;
  final double confidence;

  const AiSummary({
    required this.documentId,
    required this.summaryText,
    required this.keyPoints,
    required this.suggestedCategory,
    required this.suggestedTags,
    required this.confidence,
  });
}

enum DocumentType { invoice, receipt, resume, contract, report, letter, other }

class ExtractedData {
  final DocumentType documentType;
  final String documentTypeName;
  final double typeConfidence;
  final List<ExtractedField> fields;

  const ExtractedData({
    required this.documentType,
    required this.documentTypeName,
    required this.typeConfidence,
    required this.fields,
  });
}

class ExtractedField {
  final String key;
  final String value;
  final String label;
  final bool isCopyable;

  const ExtractedField({
    required this.key,
    required this.value,
    required this.label,
    this.isCopyable = true,
  });
}

class AiTagSuggestion {
  final String tag;
  final double relevance;
  final bool isApplied;

  const AiTagSuggestion({
    required this.tag,
    required this.relevance,
    this.isApplied = false,
  });

  AiTagSuggestion copyWith({bool? isApplied}) => AiTagSuggestion(
        tag: tag,
        relevance: relevance,
        isApplied: isApplied ?? this.isApplied,
      );
}

// ── State Classes ──────────────────────────────────────────────

class AiSummaryState {
  final AsyncValue<AiSummary> summary;
  final bool isGenerating;

  const AiSummaryState({
    this.summary = const AsyncValue.loading(),
    this.isGenerating = false,
  });

  AiSummaryState copyWith({AsyncValue<AiSummary>? summary, bool? isGenerating}) =>
      AiSummaryState(summary: summary ?? this.summary, isGenerating: isGenerating ?? this.isGenerating);
}

class AiExtractState {
  final AsyncValue<ExtractedData> data;
  final bool isExtracting;

  const AiExtractState({
    this.data = const AsyncValue.loading(),
    this.isExtracting = false,
  });

  AiExtractState copyWith({AsyncValue<ExtractedData>? data, bool? isExtracting}) =>
      AiExtractState(data: data ?? this.data, isExtracting: isExtracting ?? this.isExtracting);
}

class AiSmartRenameState {
  final AsyncValue<List<String>> suggestions;
  const AiSmartRenameState({this.suggestions = const AsyncValue.loading()});
  AiSmartRenameState copyWith({AsyncValue<List<String>>? suggestions}) =>
      AiSmartRenameState(suggestions: suggestions ?? this.suggestions);
}

class AiCategorizeState {
  final AsyncValue<String> category;
  const AiCategorizeState({this.category = const AsyncValue.loading()});
  AiCategorizeState copyWith({AsyncValue<String>? category}) =>
      AiCategorizeState(category: category ?? this.category);
}

class AiTagState {
  final AsyncValue<List<AiTagSuggestion>> tags;
  const AiTagState({this.tags = const AsyncValue.loading()});
  AiTagState copyWith({AsyncValue<List<AiTagSuggestion>>? tags}) =>
      AiTagState(tags: tags ?? this.tags);
}

class AiTranslateState {
  final AsyncValue<String> translatedText;
  final String? sourceLanguage;
  final String? targetLanguage;
  const AiTranslateState({this.translatedText = const AsyncValue.loading(), this.sourceLanguage, this.targetLanguage});
  AiTranslateState copyWith({AsyncValue<String>? translatedText, String? sourceLanguage, String? targetLanguage}) =>
      AiTranslateState(translatedText: translatedText ?? this.translatedText, sourceLanguage: sourceLanguage ?? this.sourceLanguage, targetLanguage: targetLanguage ?? this.targetLanguage);
}

// ── Notifiers ──────────────────────────────────────────────────

class AiSummaryNotifier extends StateNotifier<AiSummaryState> {
  AiSummaryNotifier() : super(const AiSummaryState());

  Future<void> generateSummary(String documentId) async {
    state = state.copyWith(isGenerating: true, summary: const AsyncValue.loading());
    try {
      await Future.delayed(const Duration(seconds: 2));
      final summary = AiSummary(
        documentId: documentId,
        summaryText: 'This is an invoice from Acme Corporation dated March 4, 2025, '
            'for cloud storage and support services. The invoice totals \$140.37 including '
            'tax of \$10.40. Payment is due within 30 days.',
        keyPoints: [
          'Invoice number: INV-2024-0892',
          'Two cloud storage plans at \$49.99 each',
          'One support package at \$29.99',
          'Tax amount: \$10.40',
          'Grand total: \$140.37',
          'Payment terms: Net 30',
        ],
        suggestedCategory: 'Invoices',
        suggestedTags: ['invoice', 'acme-corp', 'cloud-storage', 'Q1-2025', 'payment-due'],
        confidence: 0.92,
      );
      state = state.copyWith(summary: AsyncValue.data(summary), isGenerating: false);
    } catch (e, st) {
      state = state.copyWith(summary: AsyncValue.error(e, st), isGenerating: false);
    }
  }
}

class AiExtractNotifier extends StateNotifier<AiExtractState> {
  AiExtractNotifier() : super(const AiExtractState());

  Future<void> extractData(String documentId) async {
    state = state.copyWith(isExtracting: true, data: const AsyncValue.loading());
    try {
      await Future.delayed(const Duration(seconds: 2));
      final data = ExtractedData(
        documentType: DocumentType.invoice,
        documentTypeName: 'Invoice',
        typeConfidence: 0.96,
        fields: [
          const ExtractedField(key: 'merchant', value: 'Acme Corporation', label: 'Merchant'),
          const ExtractedField(key: 'invoice_number', value: 'INV-2024-0892', label: 'Invoice Number'),
          const ExtractedField(key: 'date', value: 'March 4, 2025', label: 'Date'),
          const ExtractedField(key: 'due_date', value: 'April 3, 2025', label: 'Due Date'),
          const ExtractedField(key: 'subtotal', value: '\$129.97', label: 'Subtotal'),
          const ExtractedField(key: 'tax', value: '\$10.40', label: 'Tax'),
          const ExtractedField(key: 'total', value: '\$140.37', label: 'Total'),
          const ExtractedField(key: 'email', value: 'billing@acmecorp.com', label: 'Email'),
          const ExtractedField(key: 'phone', value: '+1 (555) 234-5678', label: 'Phone'),
        ],
      );
      state = state.copyWith(data: AsyncValue.data(data), isExtracting: false);
    } catch (e, st) {
      state = state.copyWith(data: AsyncValue.error(e, st), isExtracting: false);
    }
  }
}

class AiSmartRenameNotifier extends StateNotifier<AiSmartRenameState> {
  AiSmartRenameNotifier() : super(const AiSmartRenameState());

  Future<void> suggestNames(String documentId) async {
    state = AiSmartRenameState(suggestions: const AsyncValue.loading());
    await Future.delayed(const Duration(milliseconds: 800));
    state = AiSmartRenameState(
      suggestions: AsyncValue.data([
        'Invoice_AcmeCorp_2025-03-04.pdf',
        'INV-2024-0892_Acme_Corporation.pdf',
        'Acme_Invoice_March2025.pdf',
      ]),
    );
  }
}

class AiCategorizeNotifier extends StateNotifier<AiCategorizeState> {
  AiCategorizeNotifier() : super(const AiCategorizeState());

  Future<void> categorize(String documentId) async {
    state = AiCategorizeState(category: const AsyncValue.loading());
    await Future.delayed(const Duration(milliseconds: 600));
    state = const AiCategorizeState(category: AsyncValue.data('Invoices'));
  }
}

class AiTagNotifier extends StateNotifier<AiTagState> {
  AiTagNotifier() : super(const AiTagState());

  Future<void> generateTags(String documentId) async {
    state = AiTagState(tags: const AsyncValue.loading());
    await Future.delayed(const Duration(milliseconds: 900));
    state = AiTagState(
      tags: AsyncValue.data([
        const AiTagSuggestion(tag: 'invoice', relevance: 0.98),
        const AiTagSuggestion(tag: 'acme-corp', relevance: 0.95),
        const AiTagSuggestion(tag: 'cloud-storage', relevance: 0.85),
        const AiTagSuggestion(tag: 'Q1-2025', relevance: 0.80),
        const AiTagSuggestion(tag: 'payment-due', relevance: 0.75),
      ]),
    );
  }

  void applyTag(int index) {
    final tags = state.tags.valueOrNull;
    if (tags == null || index >= tags.length) return;
    final updated = [...tags];
    updated[index] = updated[index].copyWith(isApplied: true);
    state = AiTagState(tags: AsyncValue.data(updated));
  }

  void ignoreTag(int index) {
    final tags = state.tags.valueOrNull;
    if (tags == null || index >= tags.length) return;
    final updated = [...tags]..removeAt(index);
    state = AiTagState(tags: AsyncValue.data(updated));
  }
}

class AiTranslateNotifier extends StateNotifier<AiTranslateState> {
  AiTranslateNotifier() : super(const AiTranslateState());

  Future<void> translate(String text, String sourceLang, String targetLang) async {
    state = AiTranslateState(
      translatedText: const AsyncValue.loading(),
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );
    await Future.delayed(const Duration(seconds: 1));
    final translations = {
      'hin': 'भुगतान विवरण\nकुल राशि: \$140.37\nविक्रेता: एक्मे कॉर्पोरेशन',
      'spa': 'Factura\nTotal: \$140.37\nComerciante: Acme Corporation',
      'fra': 'Facture\nTotal : 140,37 \$\nCommerçant : Acme Corporation',
      'deu': 'Rechnung\nGesamt: 140,37 \$\nHändler: Acme Corporation',
    };
    state = AiTranslateState(
      translatedText: AsyncValue.data(translations[targetLang] ?? text),
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );
  }
}

// ── Providers ──────────────────────────────────────────────────

final aiSummaryProvider = StateNotifierProvider<AiSummaryNotifier, AiSummaryState>(
  (ref) => AiSummaryNotifier(),
);

final aiKeyPointsProvider = Provider<List<String>>((ref) {
  final summary = ref.watch(aiSummaryProvider).summary.valueOrNull;
  return summary?.keyPoints ?? [];
});

final aiExtractDataProvider = StateNotifierProvider<AiExtractNotifier, AiExtractState>(
  (ref) => AiExtractNotifier(),
);

final aiSmartRenameProvider = StateNotifierProvider<AiSmartRenameNotifier, AiSmartRenameState>(
  (ref) => AiSmartRenameNotifier(),
);

final aiCategorizeProvider = StateNotifierProvider<AiCategorizeNotifier, AiCategorizeState>(
  (ref) => AiCategorizeNotifier(),
);

final aiTagProvider = StateNotifierProvider<AiTagNotifier, AiTagState>(
  (ref) => AiTagNotifier(),
);

final aiTranslateProvider = StateNotifierProvider<AiTranslateNotifier, AiTranslateState>(
  (ref) => AiTranslateNotifier(),
);

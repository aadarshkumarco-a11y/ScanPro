import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/ai_result.dart';
import '../providers/ai_provider.dart';

/// Smart rename suggestions screen.
///
/// Allows the user to input document text and the current filename,
/// then displays AI-suggested names and alternatives.
class AiSmartRenameScreen extends ConsumerStatefulWidget {
  const AiSmartRenameScreen({super.key});

  @override
  ConsumerState<AiSmartRenameScreen> createState() =>
      _AiSmartRenameScreenState();
}

class _AiSmartRenameScreenState extends ConsumerState<AiSmartRenameScreen> {
  final _textController = TextEditingController();
  final _currentNameController = TextEditingController();
  String? _selectedName;
  static const Color _primaryColor = Color(0xFF4D2DAB);

  @override
  void dispose() {
    _textController.dispose();
    _currentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final aiState = ref.watch(aiProvider);
    final isLoading = aiState.status == AiStatus.loading;
    final result = aiState.currentResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Rename'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.drive_file_rename_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI analyzes your document and suggests '
                      'descriptive, meaningful filenames.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Current Name ──────────────────────────────────────────
            Text(
              'Current Filename',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _currentNameController,
              decoration: InputDecoration(
                hintText: 'e.g. scan_2024_01_15.pdf',
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  Icons.description_outlined,
                  color: _primaryColor.withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Document Text ──────────────────────────────────────────
            Text(
              'Document Text',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Paste document text for context…',
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Suggest Button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: isLoading ? null : _suggestNames,
                icon: isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 20),
                label: Text(
                  isLoading ? 'Analyzing…' : 'Suggest Names',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Error ──────────────────────────────────────────────────
            if (aiState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        aiState.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Result ─────────────────────────────────────────────────
            if (result != null &&
                result.type == AiFeatureType.rename) ...[
              _RenameResultCard(
                result: result,
                selectedName: _selectedName,
                onNameSelected: (name) {
                  setState(() {
                    _selectedName = name;
                  });
                },
                primaryColor: _primaryColor,
              ),

              // Apply button
              if (_selectedName != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Renamed to: $_selectedName',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Apply Selected Name'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _suggestNames() async {
    final text = _textController.text.trim();
    final currentName = _currentNameController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter document text')),
      );
      return;
    }
    if (currentName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the current filename')),
      );
      return;
    }

    setState(() {
      _selectedName = null;
    });

    await ref.read(aiProvider.notifier).smartRename(
          text: text,
          currentName: currentName,
        );
  }
}

/// Card displaying rename suggestions.
class _RenameResultCard extends StatelessWidget {
  const _RenameResultCard({
    required this.result,
    required this.selectedName,
    required this.onNameSelected,
    required this.primaryColor,
  });

  final AiResult result;
  final String? selectedName;
  final ValueChanged<String> onNameSelected;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = result.metadata;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),

        // Primary suggestion
        if (metadata['suggested_name'] != null)
          _NameSuggestionTile(
            name: metadata['suggested_name'].toString(),
            isSelected: selectedName == metadata['suggested_name'].toString(),
            isPrimary: true,
            onTap: () => onNameSelected(metadata['suggested_name'].toString()),
            primaryColor: primaryColor,
          ),

        // Alternative suggestions
        if (metadata['alternatives'] is List)
          ...(metadata['alternatives'] as List).map(
            (alt) => _NameSuggestionTile(
              name: alt.toString(),
              isSelected: selectedName == alt.toString(),
              isPrimary: false,
              onTap: () => onNameSelected(alt.toString()),
              primaryColor: primaryColor,
            ),
          ),
      ],
    );
  }
}

class _NameSuggestionTile extends StatelessWidget {
  const _NameSuggestionTile({
    required this.name,
    required this.isSelected,
    required this.isPrimary,
    required this.onTap,
    required this.primaryColor,
  });

  final String name;
  final bool isSelected;
  final bool isPrimary;
  final VoidCallback onTap;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: primaryColor, width: 2)
            : BorderSide.none,
      ),
      color: isSelected
          ? primaryColor.withValues(alpha: 0.05)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? primaryColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : isPrimary
                          ? Icons.star_rounded
                          : Icons.drive_file_rename_outline_rounded,
                  color: isSelected
                      ? primaryColor
                      : isPrimary
                          ? primaryColor
                          : Colors.grey,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isPrimary ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (isPrimary)
                      Text(
                        'Best match',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: primaryColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

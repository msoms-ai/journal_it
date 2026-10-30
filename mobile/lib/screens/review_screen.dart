import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';
import '../models/media_item.dart';
import '../services/api_service.dart';
import '../services/stats_service.dart';
import 'report_screen.dart';

class ReviewScreen extends StatefulWidget {
  final List<MediaItem> files;
  final String language;
  final bool isArabic;
  final VoidCallback? onResetSession;

  const ReviewScreen({
    super.key,
    required this.files,
    required this.language,
    required this.isArabic,
    this.onResetSession,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ApiService _api = ApiService();
  bool _isSynthesizing = false;

  int get _selectedCount => widget.files.where((f) => f.isSelected && f.status == MediaStatus.completed).length;

  void _toggleSelectAll(bool? value) {
    setState(() {
      final select = value ?? false;
      for (final f in widget.files) {
        if (f.status == MediaStatus.completed) {
          f.isSelected = select;
        }
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isArabic ? 'تم نسخ النص بنجاح إلى الحافظة' : 'Copied to clipboard'),
        backgroundColor: AppTheme.crimson,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _synthesizeReport() async {
    final selectedTranscripts = widget.files
        .where((f) => f.isSelected && f.status == MediaStatus.completed && f.transcript != null)
        .map((f) => f.transcript!)
        .toList();

    if (selectedTranscripts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isArabic ? 'يرجى اختيار تسجيل واحد مفرغ على الأقل' : 'Please select at least one transcript'),
          backgroundColor: AppTheme.crimson,
        ),
      );
      return;
    }

    setState(() {
      _isSynthesizing = true;
    });

    try {
      final report = await _api.synthesizeReport(
        transcripts: selectedTranscripts,
        language: widget.language,
      );

      await StatsService.incrementReportsGenerated();

      if (!mounted) return;
      setState(() {
        _isSynthesizing = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportScreen(
            reportText: report,
            isArabic: widget.isArabic,
            sourceCount: selectedTranscripts.length,
            files: widget.files,
            onResetSession: widget.onResetSession,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSynthesizing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.isArabic;
    final allCompletedSelected = widget.files
        .where((f) => f.status == MediaStatus.completed)
        .every((f) => f.isSelected);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t ? 'مراجعة النصوص المفرغة' : 'Transcriptions Review',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Selection Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: allCompletedSelected,
                        activeColor: AppTheme.crimson,
                        onChanged: _toggleSelectAll,
                      ),
                      Text(
                        t ? 'تحديد الكل' : 'Select All',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$_selectedCount ${t ? "ملفات محددة" : "selected"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.crimson,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Transcripts List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: widget.files.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = widget.files[index];
                  final isOk = item.status == MediaStatus.completed;

                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Checkbox, Name, and Status
                          Row(
                            children: [
                              if (isOk)
                                Checkbox(
                                  value: item.isSelected,
                                  activeColor: AppTheme.crimson,
                                  onChanged: (val) {
                                    setState(() {
                                      item.isSelected = val ?? false;
                                    });
                                  },
                                )
                              else
                                const Icon(Icons.error_outline, color: Colors.red, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      item.formattedSize,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isOk && item.transcript != null)
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  tooltip: t ? 'نسخ النص' : 'Copy Text',
                                  onPressed: () => _copyToClipboard(item.transcript!),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Content preview or error
                          if (isOk && item.transcript != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              child: Text(
                                item.transcript!,
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.errorMessage ?? (t ? 'فشل التفريغ' : 'Failed to transcribe'),
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Sticky Synthesize Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_selectedCount > 0 && !_isSynthesizing)
                      ? _synthesizeReport
                      : null,
                  icon: _isSynthesizing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.auto_stories, size: 20),
                  label: Text(
                    _isSynthesizing
                        ? (t ? 'جاري صياغة التقرير...' : 'Synthesizing Report...')
                        : (t
                            ? 'صياغة التقرير الصحفي بنمط وكالات الأنباء الإماراتية ($_selectedCount)'
                            : 'Generate UAE News Agency Style Report ($_selectedCount)'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.crimson,
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

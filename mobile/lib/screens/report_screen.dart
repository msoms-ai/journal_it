import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_theme.dart';
import '../models/media_item.dart';

class ReportScreen extends StatelessWidget {
  final String reportText;
  final bool isArabic;
  final int sourceCount;
  final List<MediaItem>? files;
  final VoidCallback? onResetSession;

  const ReportScreen({
    super.key,
    required this.reportText,
    required this.isArabic,
    required this.sourceCount,
    this.files,
    this.onResetSession,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: reportText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic ? 'تم نسخ التقرير كاملاً إلى الحافظة' : 'Report copied to clipboard'),
        backgroundColor: AppTheme.crimson,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareReport() {
    SharePlus.instance.share(
      ShareParams(
        text: reportText,
        subject: isArabic ? 'تقرير صحفي — صَحِّف' : 'Official News Wire Report — Journal it',
      ),
    );
  }

  Future<void> _startNewSession(BuildContext context) async {
    // 1. Delete temporary recording/cache files
    if (files != null) {
      for (final item in files!) {
        try {
          final f = File(item.path);
          if (await f.exists()) {
            if (item.path.contains('interview_') ||
                item.path.contains('cache') ||
                item.path.contains('temp')) {
              await f.delete();
            }
          }
        } catch (_) {}
      }
    }

    // 2. Clear FilePicker temporary directory cache
    try {
      await FilePicker.clearTemporaryFiles();
    } catch (_) {}

    // 3. Pop back to HomeScreen & reset files list
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      onResetSession?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t ? 'التقرير الصحفي المعتمد' : 'Official Wire Report',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 20),
            tooltip: t ? 'مشاركة التقرير' : 'Share Report',
            onPressed: _shareReport,
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            tooltip: t ? 'نسخ التقرير' : 'Copy Report',
            onPressed: () => _copyToClipboard(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Editorial Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppTheme.crimson,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t ? 'بث إخباري رسمي — وكالة الأنباء' : 'Official News Wire Dispatch',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.crimson,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t
                                ? 'تقرير موحد صادر عن مكتب التحرير الصحفي'
                                : 'Synthesized Broadsheet Wire Report',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),

                          // Metadata row: Dateline & Byline
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t ? 'وام — مكتب الأخبار' : 'News Wire Desk',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              Text(
                                t ? 'المصادر: $sourceCount تسجيلات' : 'Sources: $sourceCount media',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Report Body Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: SelectableText(
                        reportText,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.85,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // End of wire mark
                    Center(
                      child: Text(
                        t ? '— انتهى التقرير — صَحِّف —' : '— END OF REPORT — JOURNAL IT —',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.0,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Actions Bar
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _startNewSession(context),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(t ? 'جلسة جديدة' : 'New Session'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareReport,
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(t ? 'مشاركة التقرير' : 'Share Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.crimson,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

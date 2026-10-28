import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/media_item.dart';
import '../services/api_service.dart';
import 'review_screen.dart';

class TranscribingScreen extends StatefulWidget {
  final List<MediaItem> files;
  final String language;
  final bool isArabic;

  const TranscribingScreen({
    Key? key,
    required this.files,
    required this.language,
    required this.isArabic,
  }) : super(key: key);

  @override
  State<TranscribingScreen> createState() => _TranscribingScreenState();
}

class _TranscribingScreenState extends State<TranscribingScreen> {
  final ApiService _api = ApiService();
  int _currentIndex = 0;
  String _currentFileName = '';
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _processFiles();
  }

  @override
  void dispose() {
    _isCancelled = true;
    super.dispose();
  }

  Future<void> _processFiles() async {
    for (int i = 0; i < widget.files.length; i++) {
      if (_isCancelled) return;

      final item = widget.files[i];
      setState(() {
        _currentIndex = i;
        _currentFileName = item.name;
        item.status = MediaStatus.processing;
      });

      try {
        final transcript = await _api.transcribeMedia(
          item: item,
          language: widget.language,
        );

        if (_isCancelled) return;

        setState(() {
          item.status = MediaStatus.completed;
          item.transcript = transcript;
        });
      } catch (e) {
        if (_isCancelled) return;

        setState(() {
          item.status = MediaStatus.error;
          item.errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }

    if (!_isCancelled && mounted) {
      // Proceed to Review Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewScreen(
            files: widget.files,
            language: widget.language,
            isArabic: widget.isArabic,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.isArabic;
    final total = widget.files.length;
    final progress = total > 0 ? (_currentIndex / total) : 0.0;

    return WillPopScope(
      onWillPop: () async {
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t ? 'إلغاء العملية؟' : 'Cancel Processing?'),
            content: Text(
              t
                  ? 'هل أنت متأكد من رغبتك في إلغاء تفريغ التسجيلات؟'
                  : 'Are you sure you want to stop the transcription process?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(t ? 'متابعة' : 'Continue'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  t ? 'إلغاء' : 'Cancel',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        return leave ?? false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Circular or Pulsing Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.crimson.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.crimson.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.crimson),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Step Titles
                Text(
                  t
                      ? 'تفريغ التسجيلات وتحليل المحتوى'
                      : 'Transcribing Media & Analyzing Content',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t
                      ? 'يقوم النموذج الذكي (Gemini 3.8 Flash) بالاستماع إلى التسجيل واستخراج أسماء المتحدثين بدقة...'
                      : 'Gemini 3.8 Flash is transcribing spoken words and identifying speaker identities...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Linear Progress Indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (total > 0) ? ((_currentIndex + 1) / total) : 0,
                    minHeight: 10,
                    backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.crimson),
                  ),
                ),
                const SizedBox(height: 12),

                // Current File Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t
                          ? 'الملف الحالي: $_currentFileName'
                          : 'Processing: $_currentFileName',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1} / $total',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.crimson,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Cancel Button
                OutlinedButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: Text(t ? 'إلغاء العملية' : 'Cancel Processing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

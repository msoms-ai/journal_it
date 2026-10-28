import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../config/app_theme.dart';
import '../models/media_item.dart';
import '../services/file_picker_service.dart';
import '../services/audio_recorder_service.dart';
import 'transcribing_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isArabic;
  final bool isDarkMode;
  final VoidCallback onToggleLanguage;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    Key? key,
    required this.isArabic,
    required this.isDarkMode,
    required this.onToggleLanguage,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MediaItem> _files = [];
  final AudioRecorderService _recorder = AudioRecorderService();
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final picked = await FilePickerService.pickMediaFiles();
      if (picked.isNotEmpty) {
        setState(() {
          _files.addAll(picked);
        });
      }
    } catch (e) {
      _showSnackbar(widget.isArabic ? 'حدث خطأ أثناء اختيار الملفات: $e' : 'Error picking files: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      _recordingTimer?.cancel();
      try {
        final path = await _recorder.stopRecording();
        setState(() {
          _isRecording = false;
          _recordingSeconds = 0;
        });

        if (path != null) {
          final newItem = MediaItem(
            id: const Uuid().v4(),
            name: widget.isArabic ? 'تسجيل_صوتي_مباشر.m4a' : 'live_recording.m4a',
            path: path,
            size: 256 * 1024,
            extension: 'm4a',
          );
          setState(() {
            _files.add(newItem);
          });
          _showSnackbar(widget.isArabic ? 'تم حفظ التسجيل وإضافته للقائمة بنجاح' : 'Recording saved successfully');
        }
      } catch (e) {
        setState(() {
          _isRecording = false;
        });
        _showSnackbar(widget.isArabic ? 'فشل إيقاف التسجيل: $e' : 'Failed to stop recording: $e');
      }
    } else {
      // Start recording
      try {
        final hasPerm = await _recorder.hasPermission();
        if (!hasPerm) {
          _showSnackbar(widget.isArabic ? 'يرجى منح إذن استخدام الميكروفون' : 'Microphone permission required');
          return;
        }

        await _recorder.startRecording();
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingSeconds++;
          });
        });
      } catch (e) {
        _showSnackbar(widget.isArabic ? 'تعذر بدء التسجيل: $e' : 'Could not start recording: $e');
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _files.clear();
    });
  }

  void _startJournalIt() {
    if (_files.isEmpty) {
      _showSnackbar(widget.isArabic ? 'يرجى إضافة ملف صوتي أو مرئي واحد على الأقل' : 'Please add at least one audio/video file');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TranscribingScreen(
          files: _files,
          language: widget.isArabic ? 'ar' : 'en',
          isArabic: widget.isArabic,
        ),
      ),
    );
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.crimson,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.isArabic;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tagline Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.crimson.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.crimson.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: AppTheme.crimson, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                t ? 'منصة التحرير الإخباري الذكية' : 'Smart Editorial Newsroom Studio',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: AppTheme.crimson,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t
                                ? 'تحويل المقابلات والتسجيلات الميدانية إلى تقارير صحفية رسمية متكاملة بنمط وكالات الأنباء الإماراتية'
                                : 'Transform interview recordings into professional news agency reports using Gemini 3.8 Flash',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live Mic Recording Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red.shade50 : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isRecording ? Colors.red.shade400 : Theme.of(context).colorScheme.outline,
                          width: _isRecording ? 2 : 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleRecording,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording ? Colors.red : AppTheme.crimson,
                                boxShadow: [
                                  if (_isRecording)
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isRecording
                                      ? (t ? 'جاري التسجيل المباشر...' : 'Recording live...')
                                      : (t ? 'تسجيل صوتي مباشر للمقابلة' : 'Record Live Interview'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _isRecording ? Colors.red.shade700 : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isRecording
                                      ? '${t ? "المدة:" : "Duration:"} ${_formatDuration(_recordingSeconds)}'
                                      : (t ? 'اضغط لتسجيل تصريح أو مقابلة ميدانية' : 'Tap to record audio on the spot'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // File Upload Big Button
                    InkWell(
                      onTap: _pickFiles,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            style: BorderStyle.solid,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.crimson.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                size: 32,
                                color: AppTheme.crimson,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t
                                  ? 'اضغط لاختيار تسجيلات صوت وفيديو (ملفات متعددة)'
                                  : 'Click to Upload Audio & Video Files',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t
                                  ? 'يدعم MP3, WAV, M4A, MP4, MOV وغيرها'
                                  : 'Supports MP3, WAV, M4A, MP4, MOV and more',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Uploaded Files Queue
                    if (_files.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                t ? 'قائمة التسجيلات' : 'Media Queue',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.crimson,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_files.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _clearAll,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              t ? 'مسح الكل' : 'Clear All',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _files.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _files[index];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: item.isVideo
                                          ? AppTheme.navy.withOpacity(0.1)
                                          : AppTheme.crimson.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      item.isVideo ? Icons.videocam : Icons.audiotrack,
                                      size: 20,
                                      color: item.isVideo ? AppTheme.navy : AppTheme.crimson,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: Theme.of(context).colorScheme.outline,
                                                ),
                                              ),
                                              child: Text(
                                                item.extension.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              item.formattedSize,
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
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                    onPressed: () => _removeFile(index),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Sticky Bottom Button: "Journal it !!"
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
                  onPressed: _files.isNotEmpty ? _startJournalIt : null,
                  icon: const Icon(Icons.edit_note, size: 22),
                  label: Text(
                    t ? 'صَحِّف !! (${_files.length})' : 'Journal it !! (${_files.length})',
                    style: const TextStyle(
                      fontSize: 16,
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

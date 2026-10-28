import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:intl/intl.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  String? get currentPath => _currentRecordingPath;

  /// Check & request microphone permission
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Start recording to a temporary file
  Future<String?> startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        throw Exception('إذن الميكروفون غير ممنوح');
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${tempDir.path}/interview_$timestamp.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _isRecording = true;
      _currentRecordingPath = filePath;
      return filePath;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  /// Stop recording and return final file path
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;
      final path = await _recorder.stop();
      _isRecording = false;
      return path ?? _currentRecordingPath;
    } catch (e) {
      _isRecording = false;
      rethrow;
    }
  }

  /// Cancel and delete current recording
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
      }
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _currentRecordingPath = null;
    } catch (_) {}
  }

  void dispose() {
    _recorder.dispose();
  }
}

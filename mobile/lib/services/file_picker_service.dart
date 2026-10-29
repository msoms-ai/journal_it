import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/media_item.dart';

class FilePickerService {
  static const _uuid = Uuid();

  /// Pick multiple audio or video recordings from device storage
  static Future<List<MediaItem>> pickMediaFiles() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', // Audio
          'mp4', 'mov', 'webm', 'mkv', 'avi'          // Video
        ],
      );

      if (files.isEmpty) {
        return [];
      }

      final List<MediaItem> items = [];
      for (final f in files) {
        final filePath = f.path ?? (f.uri.scheme == 'file' ? f.uri.toFilePath() : null);
        if (filePath != null) {
          final size = f.lengthSync() ?? (await f.length()) ?? (await File(filePath).length());
          final ext = f.extension ?? (f.name.contains('.') ? f.name.split('.').last : 'mp3');

          items.add(
            MediaItem(
              id: _uuid.v4(),
              name: f.name,
              path: filePath,
              size: size,
              extension: ext,
            ),
          );
        }
      }

      return items;
    } catch (e) {
      rethrow;
    }
  }
}

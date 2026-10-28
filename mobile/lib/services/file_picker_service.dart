import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/media_item.dart';

class FilePickerService {
  static const _uuid = Uuid();

  /// Pick multiple audio or video recordings from device storage
  static Future<List<MediaItem>> pickMediaFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', // Audio
          'mp4', 'mov', 'webm', 'mkv', 'avi'          // Video
        ],
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final List<MediaItem> items = [];
      for (final f in result.files) {
        if (f.path != null) {
          final file = File(f.path!);
          final size = f.size > 0 ? f.size : (await file.length());
          final ext = f.extension ?? f.name.split('.').pop() ?? 'mp3';

          items.add(
            MediaItem(
              id: _uuid.v4(),
              name: f.name,
              path: f.path!,
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

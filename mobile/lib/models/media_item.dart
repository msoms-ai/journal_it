enum MediaStatus {
  ready,
  processing,
  completed,
  error,
}

class MediaItem {
  final String id;
  final String name;
  final String path;
  final int size;
  final String extension;
  MediaStatus status;
  String? transcript;
  String? errorMessage;
  bool isSelected;

  MediaItem({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.extension,
    this.status = MediaStatus.ready,
    this.transcript,
    this.errorMessage,
    this.isSelected = true,
  });

  bool get isAudio => ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'].contains(extension.toLowerCase());
  bool get isVideo => ['mp4', 'mov', 'webm', 'mkv', 'avi'].contains(extension.toLowerCase());

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

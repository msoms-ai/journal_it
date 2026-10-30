import 'package:shared_preferences/shared_preferences.dart';

class AppStats {
  final int filesProcessed;
  final int reportsGenerated;
  final String appVersion;
  final String platformVersion;

  const AppStats({
    required this.filesProcessed,
    required this.reportsGenerated,
    this.appVersion = '1.1.0',
    this.platformVersion = '1.0',
  });
}

class StatsService {
  static const String _keyFilesProcessed = 'stats_files_processed_count';
  static const String _keyReportsGenerated = 'stats_reports_generated_count';

  static Future<AppStats> getStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final files = prefs.getInt(_keyFilesProcessed) ?? 0;
      final reports = prefs.getInt(_keyReportsGenerated) ?? 0;
      return AppStats(
        filesProcessed: files,
        reportsGenerated: reports,
      );
    } catch (_) {
      return const AppStats(filesProcessed: 0, reportsGenerated: 0);
    }
  }

  static Future<void> incrementFilesProcessed(int count) async {
    if (count <= 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyFilesProcessed) ?? 0;
      await prefs.setInt(_keyFilesProcessed, current + count);
    } catch (_) {}
  }

  static Future<void> incrementReportsGenerated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyReportsGenerated) ?? 0;
      await prefs.setInt(_keyReportsGenerated, current + 1);
    } catch (_) {}
  }
}

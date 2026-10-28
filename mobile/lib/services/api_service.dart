import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/media_item.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  /// Transcribe a single audio/video media file via the Next.js backend on Plesk
  Future<String> transcribeMedia({
    required MediaItem item,
    required String language,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          item.path,
          filename: item.name,
        ),
        'language': language,
      });

      final response = await _dio.post(
        ApiConfig.transcribeEndpoint,
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 && response.data != null) {
        final text = response.data['text'];
        if (text is String && text.trim().isNotEmpty) {
          return text.trim();
        }
        throw Exception('الخادم لم يُرجع نصاً مفرغاً');
      } else {
        throw Exception(response.data?['error'] ?? 'خطأ غير متوقع أثناء التفريغ');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('انتهت مهلة الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.');
      } else if (e.response != null) {
        final serverMsg = e.response?.data?['error'] ?? e.response?.statusMessage;
        throw Exception('خطأ من الخادم (${e.response?.statusCode}): $serverMsg');
      } else {
        throw Exception('فشل الاتصال بخادم المنصة: ${e.message}');
      }
    } catch (e) {
      throw Exception('خطأ غير متوقع: $e');
    }
  }

  /// Synthesize selected transcripts into an official UAE News Agency wire report
  Future<String> synthesizeReport({
    required List<String> transcripts,
    required String language,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.synthesizeReportEndpoint,
        data: {
          'transcripts': transcripts,
          'language': language,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final report = response.data['report'];
        if (report is String && report.trim().isNotEmpty) {
          return report.trim();
        }
        throw Exception('الخادم لم يُرجع تقريراً صياغياً');
      } else {
        throw Exception(response.data?['error'] ?? 'فشل في صياغة التقرير');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('استغرقت صياغة التقرير وقتاً طويلاً. يرجى المحاولة مرة أخرى.');
      } else if (e.response != null) {
        final serverMsg = e.response?.data?['error'] ?? e.response?.statusMessage;
        throw Exception('خطأ من الخادم: $serverMsg');
      } else {
        throw Exception('فشل في الوصول للخادم: ${e.message}');
      }
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }
}

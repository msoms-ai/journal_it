class ApiConfig {
  // Remote production backend on Plesk
  static const String baseUrl = 'https://sahhef.msoms.ai';

  // API Endpoints
  static const String transcribeEndpoint = '/api/transcribe';
  static const String synthesizeReportEndpoint = '/api/synthesize-report';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 45);
  static const Duration sendTimeout = Duration(seconds: 120);
  static const Duration receiveTimeout = Duration(seconds: 180);
}

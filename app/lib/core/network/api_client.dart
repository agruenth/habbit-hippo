import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080', // Android emulator localhost
  );

  static final Dio _dio = _build();

  static Dio get instance => _dio;

  static Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefresh(dio);
          if (refreshed) {
            final opts = error.requestOptions;
            final token = await SecureStorage.getAccessToken();
            opts.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch(opts);
            return handler.resolve(response);
          }
        }
        handler.next(error);
      },
    ));
    return dio;
  }

  static Future<bool> _tryRefresh(Dio dio) async {
    final refresh = await SecureStorage.getRefreshToken();
    if (refresh == null) return false;
    try {
      final resp = await Dio(BaseOptions(baseUrl: baseUrl)).post(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      await SecureStorage.saveTokens(
        access: resp.data['access_token'],
        refresh: resp.data['refresh_token'],
      );
      return true;
    } catch (_) {
      await SecureStorage.clear();
      return false;
    }
  }
}

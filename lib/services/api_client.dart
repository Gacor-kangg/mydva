import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'api_exception.dart';

/// Pabrik [Dio] bersama untuk semua service (TMDB, AniList, Kitsu).
///
/// Satu tempat untuk timeout, header dasar, retry, dan log.
class ApiClient {
  ApiClient._();

  static Dio create({
    required String baseUrl,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        // sendTimeout sengaja tidak diisi: tidak didukung untuk request
        // tanpa body di Flutter Web.
        connectTimeout: ApiConfig.requestTimeout,
        receiveTimeout: ApiConfig.requestTimeout,
        headers: headers,
        queryParameters: queryParameters ?? const {},
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(_RetryInterceptor(dio));

    if (kDebugMode) {
      // Header tidak dicetak agar token TMDB tidak bocor ke log.
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }

    return dio;
  }

  /// Memastikan body respons berupa JSON object.
  ///
  /// Beberapa API (mis. Kitsu dengan `application/vnd.api+json`) bisa
  /// mengirim body sebagai String, jadi dicoba didekode manual.
  static Map<String, dynamic> asJsonMap(dynamic data, {required String source}) {
    dynamic value = data;

    if (value is String) {
      try {
        value = jsonDecode(value);
      } on FormatException {
        throw ApiException('Respons $source tidak dapat dibaca.');
      }
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw ApiException('Format respons $source tidak valid.');
  }
}

/// Mengulang request GET yang gagal karena jaringan atau server (5xx).
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;
  static const int maxRetries = 2;

  static const _retryKey = 'retry_count';

  bool _shouldRetry(DioException err, int attempt) {
    if (err.requestOptions.method != 'GET' || attempt >= maxRetries) {
      return false;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        return status == 502 || status == 503 || status == 504;
      default:
        return false;
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_retryKey] as int?) ?? 0;

    if (!_shouldRetry(err, attempt)) {
      return handler.next(err);
    }

    await Future<void>.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    options.extra[_retryKey] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }
}

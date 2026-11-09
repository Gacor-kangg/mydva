import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  /// Mengubah [DioException] menjadi pesan yang ramah untuk pengguna.
  factory ApiException.fromDio(DioException error, {required String source}) {
    final status = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          'Koneksi ke $source terlalu lama. Silakan coba lagi.',
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Tidak dapat terhubung ke $source. Periksa koneksi internet.',
        );
      case DioExceptionType.badResponse:
        if (status == 401 || status == 403) {
          return ApiException(
            'Akses ke $source ditolak. Periksa token/API key.',
            statusCode: status,
          );
        }
        if (status == 429) {
          return ApiException(
            'Terlalu banyak permintaan ke $source. Coba lagi sebentar lagi.',
            statusCode: status,
          );
        }
        return ApiException(
          '$source gagal merespons.',
          statusCode: status,
        );
      case DioExceptionType.cancel:
        return ApiException('Permintaan ke $source dibatalkan.');
      case DioExceptionType.badCertificate:
        return ApiException('Sertifikat keamanan $source tidak valid.');
      case DioExceptionType.unknown:
        return ApiException('Terjadi kesalahan saat menghubungi $source.');
    }
  }

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException ($statusCode): $message';
    }

    return 'ApiException: $message';
  }
}

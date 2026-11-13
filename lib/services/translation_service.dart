import 'package:dio/dio.dart';

/// Penerjemah sinopsis ke Bahasa Indonesia menggunakan endpoint web Google
/// Translate (GTX). Endpoint ini tidak memerlukan API key, tetapi bukan API
/// resmi Google Cloud Translation dan dapat berubah sewaktu-waktu.
class TranslationService {
  final Dio _dio;

  TranslationService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: 'https://translate.googleapis.com',
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 12),
          headers: {'Accept': 'application/json'},
        ));

  Future<String> toIndonesian(String text) async {
    final source = text.trim();
    if (source.isEmpty) return source;

    // Pecah teks panjang agar URL request tidak terlalu besar.
    final chunks = _splitText(source, 3000);
    final translated = <String>[];

    for (final chunk in chunks) {
      final response = await _dio.get<dynamic>(
        '/translate_a/single',
        queryParameters: {
          'client': 'gtx',
          'sl': 'auto',
          'tl': 'id',
          'dt': 't',
          'q': chunk,
        },
      );

      final data = response.data;
      if (data is! List || data.isEmpty || data[0] is! List) {
        throw const FormatException('Respons Google Translate tidak valid.');
      }

      final segments = data[0] as List;
      final buffer = StringBuffer();
      for (final segment in segments) {
        if (segment is List && segment.isNotEmpty && segment[0] is String) {
          buffer.write(segment[0]);
        }
      }

      final result = buffer.toString().trim();
      if (result.isEmpty) {
        throw const FormatException('Hasil terjemahan kosong.');
      }
      translated.add(result);
    }

    return translated.join('\n\n');
  }

  List<String> _splitText(String text, int maxLength) {
    if (text.length <= maxLength) return [text];

    final paragraphs = text.split(RegExp(r'\n\s*\n'));
    final chunks = <String>[];
    var current = StringBuffer();

    for (final paragraph in paragraphs) {
      if (paragraph.length > maxLength) {
        if (current.isNotEmpty) {
          chunks.add(current.toString().trim());
          current = StringBuffer();
        }
        for (var start = 0; start < paragraph.length; start += maxLength) {
          final end = (start + maxLength < paragraph.length)
              ? start + maxLength
              : paragraph.length;
          chunks.add(paragraph.substring(start, end));
        }
        continue;
      }

      final addition = current.isEmpty ? paragraph : '\n\n$paragraph';
      if (current.length + addition.length > maxLength) {
        chunks.add(current.toString().trim());
        current = StringBuffer(paragraph);
      } else {
        current.write(addition);
      }
    }

    if (current.isNotEmpty) chunks.add(current.toString().trim());
    return chunks;
  }

  void dispose() => _dio.close();
}

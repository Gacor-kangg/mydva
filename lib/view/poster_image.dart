import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/media_model.dart';

class PosterImage extends StatelessWidget {
  final MediaModel media;
  final double? width;
  final double? height;
  final Color placeholderColor;
  final Color textColor;
  final double textSize;

  const PosterImage({
    super.key,
    required this.media,
    this.width,
    this.height,
    this.placeholderColor = const Color(0xFF2A2A2A),
    this.textColor = const Color(0xFF777777),
    this.textSize = 28,
  });

  Widget _placeholder() {
    final title = media.title;

    return Container(
      width: width,
      height: height,
      color: placeholderColor,
      alignment: Alignment.center,
      child: Text(
        title.isEmpty ? '?' : title[0].toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: textSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final src = media.imageUrl.trim();

    // Hanya menerima poster dari URL API.
    if (!src.startsWith('https://') && !src.startsWith('http://')) {
      return _placeholder();
    }

    return Container(
      width: width,
      height: height,
      color: placeholderColor,
      child: CachedNetworkImage(
        imageUrl: src,
        width: width,
        height: height,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 450),
        placeholder: (context, url) => _placeholder(),
        errorWidget: (context, url, error) {
          debugPrint('Gagal memuat poster ${media.title}: $error');
          return _placeholder();
        },
      ),
    );
  }
}

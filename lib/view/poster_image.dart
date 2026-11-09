import 'package:flutter/material.dart';

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

  Widget _fadeIn(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;

    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final src = media.imageUrl;
    if (src.isEmpty) return _placeholder();

    final Widget image;

    if (src.startsWith('http')) {
      image = Image.network(
        src,
        width: width,
        height: height,
        fit: BoxFit.cover,
        frameBuilder: _fadeIn,
        // Di web, CDN tanpa header CORS (mis. Kitsu) gagal dimuat sebagai
        // canvas; mode ini otomatis jatuh ke elemen <img> biasa.
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    } else {
      image = Image.asset(
        src,
        width: width,
        height: height,
        fit: BoxFit.cover,
        frameBuilder: _fadeIn,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    return Container(
      width: width,
      height: height,
      color: placeholderColor,
      child: image,
    );
  }
}

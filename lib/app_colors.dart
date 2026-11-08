import 'package:flutter/material.dart';

/// Warna bersama untuk seluruh aplikasi.
/// Halaman baru/upgrade memakai file ini, jadi mengubah satu warna
/// cukup di sini saja.
class AppColors {
  AppColors._();

  // Latar
  static const Color background = Color(0xFF0B0B0C);
  static const Color panel = Color(0xFF151516);
  static const Color card = Color(0xFF1B1B1D);
  static const Color border = Color(0xFF2A2A2D);

  // Aksen
  static const Color blue = Color(0xFF4A6FC3);
  static const Color lightBlue = Color(0xFF9DBEFF);

  // Status
  static const Color green = Color(0xFF3FA35B);
  static const Color yellow = Color(0xFFD1A91A);
  static const Color red = Color(0xFF963434);
  static const Color danger = Color(0xFFE57373);

  // Teks
  static const Color mutedText = Color(0xFF8E8E93);
  static const Color softText = Color(0xFFC8C8CC);
}

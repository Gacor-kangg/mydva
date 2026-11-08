import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'ui_effects.dart';

/// Data satu anggota tim.
/// - [foto]      : path asset, mis. 'assets/members/maksima.jpg'.
/// - [deskripsi] : perkenalan singkat tentang anggota.
class _Member {
  final String nama;
  final String nim;
  final String deskripsi;
  final String? foto;

  const _Member({
    required this.nama,
    required this.nim,
    required this.deskripsi,
    this.foto,
  });
}

class AboutApplicationPage extends StatelessWidget {
  const AboutApplicationPage({super.key});

  // ============================================================
  // DATA ANGGOTA (edit di sini)
  // ============================================================

  static const List<_Member> members = [
    _Member(
      nama: 'Maksima Insan A',
      nim: '25051204438',
      deskripsi:
          'Ceritakan sedikit tentang dirimu, minat, dan kontribusimu di proyek ini.',
      foto: 'assets/members/maksima.jpg',
    ),
    _Member(
      nama: 'Najwan Fairuz Z',
      nim: '25051204437',
      deskripsi:
          'hebad kamu mas',
      foto: 'assets/najwan.jpeg',
    ),
    _Member(
      nama: 'Geacealsia Shello A',
      nim: '25051204421',
      deskripsi:
          'Ceritakan sedikit tentang dirimu, minat, dan kontribusimu di proyek ini.',
      foto: 'assets/members/geacealsia.jpg',
    ),
    _Member(
      nama: 'Saha',
      nim: '21',
      deskripsi:
          'Ceritakan sedikit tentang dirimu, minat, dan kontribusimu di proyek ini.',
      foto: 'assets/members/saha.jpg',
    ),
    _Member(
      nama: 'Tri',
      nim: '12',
      deskripsi:
          'Ceritakan sedikit tentang dirimu, minat, dan kontribusimu di proyek ini.',
      foto: 'assets/members/tri.jpg',
    ),
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'About Application',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Reveal(child: _buildHero()),
                const SizedBox(height: 28),
                Reveal(
                  delay: const Duration(milliseconds: 120),
                  child: _buildAboutCard(),
                ),
                const SizedBox(height: 34),
                const Reveal(
                  delay: Duration(milliseconds: 220),
                  child: _SectionTitle('Kenalan dengan Tim'),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Orang-orang di balik pembuatan aplikasi ini.',
                  style: TextStyle(color: AppColors.mutedText, fontSize: 13),
                ),
                const SizedBox(height: 18),
                _buildTeamGrid(),
                const SizedBox(height: 36),
                const Center(
                  child: Text(
                    '© 2026 MYDVA Development Team',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2A47), AppColors.card],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightBlue, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/pnp.jpg',
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 84,
                  height: 84,
                  color: AppColors.panel,
                  child: const Icon(Icons.movie_outlined,
                      color: AppColors.lightBlue, size: 36),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'MYDVA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Katalog Film, Series & Anime',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.softText, fontSize: 14),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x334A6FC3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Versi 1.0.0',
              style: TextStyle(color: AppColors.lightBlue, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TENTANG APLIKASI
  // ============================================================

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Tentang Aplikasi'),
          SizedBox(height: 12),
          Text(
            'Aplikasi ini dikembangkan sebagai bagian dari proyek '
            'pembelajaran untuk menerapkan pengetahuan dan keterampilan '
            'dalam bidang pengembangan aplikasi.',
            style: TextStyle(
              color: AppColors.softText,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRID ANGGOTA TIM
  // ============================================================

  Widget _buildTeamGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final w = constraints.maxWidth;
        final columns = w >= 820 ? 3 : (w >= 560 ? 2 : 1);
        final cardWidth = (w - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (int i = 0; i < members.length; i++)
              SizedBox(
                width: cardWidth,
                child: Reveal(
                  delay: Duration(milliseconds: 280 + i * 90),
                  child: _MemberCard(
                    member: members[i],
                    horizontal: columns == 1,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ==============================================================
// JUDUL SECTION
// ==============================================================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ==============================================================
// KARTU PERKENALAN ANGGOTA
// ==============================================================

class _MemberCard extends StatelessWidget {
  final _Member member;

  /// true  -> foto di kiri, teks di kanan (untuk layar sempit)
  /// false -> foto di atas, teks di bawah
  final bool horizontal;

  const _MemberCard({required this.member, required this.horizontal});

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      hoverScale: 1.02,
      radius: 10,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: horizontal ? _buildHorizontal() : _buildVertical(),
      ),
    );
  }

  Widget _buildVertical() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: 1, child: _photo()),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _info(),
        ),
      ],
    );
  }

  Widget _buildHorizontal() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 110, child: _photo()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _info(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          member.nama,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'NIM: ${member.nim}',
          style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Text(
          member.deskripsi,
          style: const TextStyle(
            color: AppColors.softText,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Foto anggota. Kalau file belum ada, tampil inisial nama.
  Widget _photo() {
    final path = member.foto;

    final fallback = Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B3F6B), Color(0xFF1B1B1D)],
        ),
      ),
      child: Text(
        member.nama.isEmpty ? '?' : member.nama[0].toUpperCase(),
        style: const TextStyle(
          color: AppColors.lightBlue,
          fontSize: 52,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (path == null || path.isEmpty) return fallback;

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
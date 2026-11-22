import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_colors.dart';
import 'ui_effects.dart';

class _Member {
  final String nama;
  final String nim;
  final String deskripsi;
  final String? foto;
  final String? github;
  final String? instagram;

  const _Member({
    required this.nama,
    required this.nim,
    required this.deskripsi,
    this.foto,
    this.github,
    this.instagram,
  });
}

class AboutApplicationPage extends StatelessWidget {
  const AboutApplicationPage({super.key});

  // ============================================================
  // DATA ANGGOTA
  // ============================================================

  static const List<_Member> members = [
    _Member(
      nama: 'Maksima Insan A',
      nim: '25051204438',
      deskripsi:
          'I for insyaalllah.',
      foto: 'assets/members/maksima.jpg',
    ),
    _Member(
      nama: 'Najwan Fairuz Z',
      nim: '25051204437',
      deskripsi:
          'is it better to speak or to die',
      foto: 'assets/members/najwan.jpeg',
      github: 'floonly',
      instagram: 'sassannnnnnn',
    ),
    _Member(
      nama: 'Geacealsia Shello A',
      nim: '25051204421',
      deskripsi:
          'Ceritakan sedikit tentang dirimu, minat, dan kontribusimu di proyek ini.',
      foto: 'assets/members/gea.jpeg',
    ),
    _Member(
      nama: 'Sakarina Harera',
      nim: '25051204407',
      deskripsi:
          'you.only.live.once.do.it.',
      foto: 'assets/members/sakarina.jpeg',
    ),
    _Member(
      nama: 'Tri Oktavia R ',
      nim: '25051204413',
      deskripsi:
          'Tidak harus menjadi yang tercepat, cukup jangan berhenti melangkah.',
      foto: 'assets/members/tri.jpeg',
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
                  delay: Duration(milliseconds: 180),
                  child: _SectionTitle('Fitur Utama'),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Yang bisa kamu lakukan di MYDVA.',
                  style: TextStyle(color: AppColors.mutedText, fontSize: 13),
                ),
                const SizedBox(height: 18),
                _buildFeatureGrid(),
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
                'assets/logo.png',
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
            'MYDVA adalah aplikasi yang dirancang untuk membantu pengguna menemukan, menjelajahi, dan mengelola daftar tontonan film, series, anime, J-Drama, dan K-Drama. Aplikasi ini menyediakan informasi media, rating, sinopsis, serta fitur pengelolaan My List dalam satu platform.',
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
  // GRID FITUR
  // ============================================================

  static const List<_Feature> _features = [
    _Feature(
      '01',
      'Katalog Lengkap',
      'Jelajahi film, series, dan anime dalam satu tempat, lengkap dengan '
          'sinopsis, pemeran, dan trailer.',
    ),
    _Feature(
      '02',
      'My List',
      'Simpan judul ke daftarmu, lengkap dengan status tontonan dan rating '
          'pribadi.',
    ),
    _Feature(
      '03',
      'Progress Episode',
      'Catat sampai episode berapa kamu menonton, bisa langsung diketik.',
    ),
    _Feature(
      '04',
      'Statistik Profil',
      'Lihat ringkasan tontonan, sebaran skor, dan aktivitas terbarumu.',
    ),
  ];

  Widget _buildFeatureGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final w = constraints.maxWidth;
        final columns = w >= 820 ? 4 : (w >= 560 ? 2 : 1);
        final cardWidth = (w - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (int i = 0; i < _features.length; i++)
              SizedBox(
                width: cardWidth,
                child: Reveal(
                  delay: Duration(milliseconds: 200 + i * 80),
                  child: _FeatureCard(feature: _features[i]),
                ),
              ),
          ],
        );
      },
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
        const SizedBox(height: 14),
        _SocialButtons(github: member.github, instagram: member.instagram),
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

// ==============================================================
// FITUR UTAMA
// ==============================================================

class _Feature {
  final String number;
  final String title;
  final String description;

  const _Feature(this.number, this.title, this.description);
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      hoverScale: 1.03,
      radius: 10,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              feature.number,
              style: const TextStyle(
                color: AppColors.lightBlue,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              feature.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              feature.description,
              style: const TextStyle(
                color: AppColors.softText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================
// TOMBOL GITHUB & INSTAGRAM
// ==============================================================

/// Ubah username (atau link lengkap) menjadi URL. Kosong -> null.
String? _profileUrl(String base, String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  if (v.startsWith('http://') || v.startsWith('https://')) return v;
  return '$base${v.startsWith('@') ? v.substring(1) : v}';
}

class _SocialButtons extends StatelessWidget {
  final String? github;
  final String? instagram;

  const _SocialButtons({this.github, this.instagram});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SocialButton(
          label: 'GitHub',
          url: _profileUrl('https://github.com/', github),
        ),
        _SocialButton(
          label: 'Instagram',
          url: _profileUrl('https://www.instagram.com/', instagram),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String? url;

  const _SocialButton({required this.label, required this.url});

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final target = url;

    if (target == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Link $label belum diisi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    bool opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(target),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Tidak bisa membuka $label.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = url != null;

    return Material(
      color: enabled ? const Color(0x224A6FC3) : AppColors.panel,
      shape: StadiumBorder(
        side: BorderSide(
          color: enabled ? AppColors.blue : AppColors.border,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        hoverColor: const Color(0x334A6FC3),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? AppColors.lightBlue : AppColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
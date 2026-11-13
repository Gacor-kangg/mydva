import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

import 'about_application_page.dart';
import 'app_colors.dart';
import '../models/media_model.dart';
import 'poster_image.dart';
import 'ui_effects.dart';
import '../repositories/media_repository.dart';
import '../services/tmdb_service.dart';
import '../services/anilist_service.dart';
import '../services/kitsu_service.dart';

enum _AuthMode { login, register, forgot }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // STATE
  // ============================================================

  late final AnimationController _wallController;
  late final MediaRepository _mediaRepository;
  late final AuthController _authController;

  List<List<MediaModel>> _wallColumns = [[], [], []];

  int _movieCount = 0;
  int _seriesCount = 0;
  int _animeCount = 0;

  bool _wallLoading = true;
  String? _wallError;

  _AuthMode _mode = _AuthMode.login;
  bool _loading = false;
  bool _remember = false;
  bool _showPassword = false;

  /// Pesan error per kolom, contoh: _errors['loginId'].
  final Map<String, String> _errors = {};

  /// Pesan info di atas form (misalnya setelah daftar).
  String? _notice;

  // Login
  final TextEditingController _loginId = TextEditingController();
  final TextEditingController _loginPass = TextEditingController();

  // Register
  final TextEditingController _regUser = TextEditingController();
  final TextEditingController _regEmail = TextEditingController();
  final TextEditingController _regPass = TextEditingController();
  final TextEditingController _regConfirm = TextEditingController();

  // Lupa password
  final TextEditingController _forgotEmail = TextEditingController();

  @override
  void initState() {
    super.initState();

    _wallController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();

    _authController = AuthController(
      repository: AuthRepository(service: AuthService()),
    );

    _mediaRepository = MediaRepository(
      tmdbService: TmdbService(),
      anilistService: AnilistService(),
      kitsuService: KitsuService(),
    );

    _loadWallPosters();
  }

  @override
  void dispose() {
    _wallController.dispose();
    _mediaRepository.dispose();

    _loginId.dispose();
    _loginPass.dispose();
    _regUser.dispose();
    _regEmail.dispose();
    _regPass.dispose();
    _regConfirm.dispose();
    _forgotEmail.dispose();

    super.dispose();
  }

// ============================================================
// DATA DINDING POSTER DARI API
// ============================================================

  Future<void> _loadWallPosters() async {
    if (mounted) {
      setState(() {
        _wallLoading = true;
        _wallError = null;
      });
    }

    // Masing-masing sumber ditangani secara terpisah.
    // Jika satu API gagal, poster dari API lain tetap digunakan.
    Future<List<MediaModel>> loadSafely(
      Future<List<MediaModel>> future,
      String source,
    ) async {
      try {
        return await future;
      } catch (error) {
        debugPrint('Gagal mengambil poster $source: $error');
        return [];
      }
    }

    final results = await Future.wait([
      loadSafely(
        _mediaRepository.getMovies(page: 1),
        'TMDB Film',
      ),
      loadSafely(
        _mediaRepository.getSeries(page: 1),
        'TMDB Series',
      ),
      loadSafely(
        _mediaRepository.getAnime(page: 1, perPage: 20),
        'AniList dan Kitsu',
      ),
    ]);

    final movies = results[0];
    final series = results[1];
    final anime = results[2];

    // Hanya menggunakan poster dari URL API.
    final apiMovies = movies
        .where((item) => item.imageUrl.startsWith('http'))
        .toList();

    final apiSeries = series
        .where((item) => item.imageUrl.startsWith('http'))
        .toList();

    final apiAnime = anime
        .where((item) => item.imageUrl.startsWith('http'))
        .toList();

    // Susun poster secara bergantian:
    // Film -> Series -> Anime.
    final mixed = <MediaModel>[];

    final longest = [
      apiMovies.length,
      apiSeries.length,
      apiAnime.length,
    ].reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < longest; i++) {
      if (i < apiMovies.length) {
        mixed.add(apiMovies[i]);
      }

      if (i < apiSeries.length) {
        mixed.add(apiSeries[i]);
      }

      if (i < apiAnime.length) {
        mixed.add(apiAnime[i]);
      }
    }

    // Bagi poster ke tiga kolom.
    final columns = <List<MediaModel>>[
      [],
      [],
      [],
    ];

    for (int i = 0; i < mixed.length && i < 60; i++) {
      columns[i % 3].add(mixed[i]);
    }

    if (!mounted) return;

    setState(() {
      _movieCount = apiMovies.length;
      _seriesCount = apiSeries.length;
      _animeCount = apiAnime.length;

      _wallColumns = columns;

      _wallLoading = false;

      if (mixed.isEmpty) {
        _wallError = 'Poster belum dapat dimuat dari API.';
      } else {
        _wallError = null;
      }
    });
  }

  // ============================================================
  // AKSI
  // ============================================================

  void _setMode(_AuthMode mode, {String? notice}) {
    setState(() {
      _mode = mode;
      _notice = notice;
      _errors.clear();
      _showPassword = false;
      _loading = false;
    });
  }

  void _clearError(String key) {
    if (_errors.containsKey(key)) {
      setState(() => _errors.remove(key));
    }
  }

  bool _validEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  // ----------------------------------------------------------
  // FIREBASE AUTHENTICATION
  // ----------------------------------------------------------

  Future<String?> _authenticate(String email, String password) {
    return _authController.signIn(email: email, password: password);
  }

  Future<String?> _registerAccount(
    String username,
    String email,
    String password,
  ) {
    return _authController.register(
      username: username,
      email: email,
      password: password,
    );
  }

  Future<String?> _sendResetLink(String email) {
    return _authController.sendPasswordResetEmail(email);
  }

  Future<void> _submitGoogleLogin() async {
    setState(() {
      _errors.clear();
      _notice = null;
      _loading = true;
    });

    final error = await _authController.signInWithGoogle();
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _loading = false;
        _notice = error;
      });
    }
  }

  Future<void> _submitLogin() async {
    final id = _loginId.text.trim();
    final pass = _loginPass.text;

    final errors = <String, String>{};
    if (id.isEmpty) errors['loginId'] = 'Masukkan email';
    if (pass.isEmpty) errors['loginPass'] = 'Masukkan password';

    if (errors.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll(errors);
      });
      return;
    }

    setState(() {
      _errors.clear();
      _notice = null;
      _loading = true;
    });

    final error = await _authenticate(id, pass);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _loading = false;
        _errors['loginPass'] = error;
      });
      return;
    }

    // AuthGate akan berpindah ke HomePage saat Firebase mengubah status login.

  }

  Future<void> _submitRegister() async {
    final user = _regUser.text.trim();
    final email = _regEmail.text.trim();
    final pass = _regPass.text;
    final confirm = _regConfirm.text;

    final errors = <String, String>{};
    if (user.length < 3) errors['regUser'] = 'Username minimal 3 karakter';
    if (!_validEmail(email)) errors['regEmail'] = 'Masukkan email yang valid';
    if (pass.length < 6) errors['regPass'] = 'Password minimal 6 karakter';
    if (confirm != pass) errors['regConfirm'] = 'Password tidak sama';

    if (errors.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll(errors);
      });
      return;
    }

    setState(() {
      _errors.clear();
      _loading = true;
    });

    final error = await _registerAccount(user, email, pass);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _loading = false;
        _errors['regEmail'] = error;
      });
      return;
    }

    _loginId.text = email;
    _loginPass.clear();
    _setMode(_AuthMode.login, notice: 'Akun dibuat. Silakan masuk.');
  }

  Future<void> _submitForgot() async {
    final email = _forgotEmail.text.trim();

    if (!_validEmail(email)) {
      setState(() {
        _errors
          ..clear()
          ..['forgotEmail'] = 'Masukkan email yang valid';
      });
      return;
    }

    setState(() {
      _errors.clear();
      _loading = true;
    });

    final error = await _sendResetLink(email);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _loading = false;
        _errors['forgotEmail'] = error;
      });
      return;
    }

    _loginId.text = email;
    _setMode(
      _AuthMode.login,
      notice: 'Link untuk mengatur ulang password dikirim ke $email.',
    );
  }

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutApplicationPage()),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;

          if (wide) {
            return Row(
              children: [
                Expanded(flex: 11, child: _buildBrandPanel()),
                Expanded(flex: 10, child: _buildFormPanel(wide: true)),
              ],
            );
          }

          return Stack(
            children: [
              Positioned.fill(child: _buildBackdrop()),
              _buildFormPanel(wide: false),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // PANEL KIRI: DINDING POSTER + NAMA APLIKASI (layar lebar)
  // ============================================================

  Widget _buildBrandPanel() {
    return Container(
      color: const Color(0xFF101114),
      child: Stack(
        children: [
          Positioned.fill(child: _buildPosterWall()),

          // Gelapkan poster supaya teks mudah dibaca
          Positioned.fill(
            child: Container(color: const Color(0x990B0B0C)),
          ),

          // Gradasi di bagian bawah untuk teks
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x000B0B0C), Color(0xF20B0B0C)],
                ),
              ),
            ),
          ),

          // Logo
          Positioned(
            top: 26,
            left: 30,
            child: Reveal(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'assets/pnp.jpg',
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'MYDVA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tagline + jumlah judul
          Positioned(
            left: 30,
            right: 30,
            bottom: 34,
            child: Reveal(
              delay: const Duration(milliseconds: 250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catat, nilai, dan diskusikan film, series, dan anime.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _countItem(_movieCount, 'Film'),
                      const SizedBox(width: 28),
                      _countItem(_seriesCount, 'Series'),
                      const SizedBox(width: 28),
                      _countItem(_animeCount, 'Anime'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countItem(int count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LATAR POSTER (layar sempit)
  // ============================================================

  Widget _buildBackdrop() {
    return Stack(
      children: [
        Positioned.fill(child: _buildPosterWall()),
        Positioned.fill(child: Container(color: const Color(0xE60B0B0C))),
      ],
    );
  }

  // ============================================================
  // DINDING POSTER (3 kolom bergeser pelan)
  // ============================================================

  Widget _buildPosterWall() {
    if (_wallLoading) {
      return const ColoredBox(
        color: Color(0xFF101114),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_wallColumns.every((column) => column.isEmpty)) {
      return Container(
        color: const Color(0xFF101114),
        alignment: Alignment.center,
        child: Text(
          _wallError ?? 'Poster tidak tersedia',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        const pad = 16.0;

        final count = _wallColumns.length;
        final colWidth =
            (constraints.maxWidth - pad * 2 - gap * (count - 1)) / count;
        final itemHeight = colWidth * 1.5;

        return ClipRect(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: pad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < count; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  _buildWallColumn(
                    items: _wallColumns[i],
                    width: colWidth,
                    itemHeight: itemHeight,
                    gap: gap,
                    panelHeight: constraints.maxHeight,
                    up: i.isEven,
                    phase: i * 0.33,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWallColumn({
    required List<MediaModel> items,
    required double width,
    required double itemHeight,
    required double gap,
    required double panelHeight,
    required bool up,
    required double phase,
  }) {
    final setHeight = items.length * (itemHeight + gap);
    final repeats = (panelHeight / setHeight).ceil() + 1;

    return SizedBox(
      width: width,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _wallController,
          builder: (context, _) {
            final t = (_wallController.value + phase) % 1.0;
            final dy = up ? -t * setHeight : -(1 - t) * setHeight;

            return OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 0,
              maxHeight: double.infinity,
              child: Transform.translate(
                offset: Offset(0, dy),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int r = 0; r < repeats; r++)
                      for (final item in items)
                        Padding(
                          padding: EdgeInsets.only(bottom: gap),
                          child: SizedBox(
                            width: width,
                            height: itemHeight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: PosterImage(
                                media: item,
                                width: width,
                                height: itemHeight,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // PANEL FORM
  // ============================================================

  Widget _buildFormPanel({required bool wide}) {
    final form = _buildSwitcher();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Reveal(
            delay: const Duration(milliseconds: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (wide)
                  form
                else
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xF2151516),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: form,
                  ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: _openAbout,
                  child: const Text(
                    'Tentang aplikasi',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Isi form berganti dengan fade saat pindah login / daftar / lupa password.
  Widget _buildSwitcher() {
    final Widget content;

    switch (_mode) {
      case _AuthMode.login:
        content = _buildLoginForm();
        break;
      case _AuthMode.register:
        content = _buildRegisterForm();
        break;
      case _AuthMode.forgot:
        content = _buildForgotForm();
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: SizedBox(
        key: ValueKey(_mode),
        width: double.infinity,
        child: content,
      ),
    );
  }

  // ----------------------------------------------------------
  // FORM: LOGIN
  // ----------------------------------------------------------

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'Selamat datang kembali',
          'Masuk untuk melihat daftar dan progresmu.',
        ),
        _noticeBox(),
        _AuthField(
          label: 'Email',
          controller: _loginId,
          error: _errors['loginId'],
          textInputAction: TextInputAction.next,
          onChanged: (_) => _clearError('loginId'),
        ),
        const SizedBox(height: 14),
        _AuthField(
          label: 'Password',
          controller: _loginPass,
          obscure: !_showPassword,
          onToggleObscure: () => setState(() => _showPassword = !_showPassword),
          error: _errors['loginPass'],
          onChanged: (_) => _clearError('loginPass'),
          onSubmitted: (_) => _submitLogin(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ToggleChip(
              label: 'Ingat saya',
              selected: _remember,
              onTap: () => setState(() => _remember = !_remember),
            ),
            const Spacer(),
            _linkButton(
              'Lupa password?',
              () => _setMode(_AuthMode.forgot),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _PrimaryButton(
          label: 'Masuk',
          loading: _loading,
          onPressed: _submitLogin,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loading ? null : _submitGoogleLogin,
            icon: const Icon(Icons.g_mobiledata, size: 26),
            label: const Text('Lanjutkan dengan Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.24)),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _footer(
          'Belum punya akun?',
          'Daftar',
          () => _setMode(_AuthMode.register),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // FORM: DAFTAR
  // ----------------------------------------------------------

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'Buat akun baru',
          'Simpan daftar tontonan dan progresmu di satu tempat.',
        ),
        _AuthField(
          label: 'Username',
          controller: _regUser,
          error: _errors['regUser'],
          textInputAction: TextInputAction.next,
          onChanged: (_) => _clearError('regUser'),
        ),
        const SizedBox(height: 14),
        _AuthField(
          label: 'Email',
          controller: _regEmail,
          hint: 'nama@email.com',
          keyboardType: TextInputType.emailAddress,
          error: _errors['regEmail'],
          textInputAction: TextInputAction.next,
          onChanged: (_) => _clearError('regEmail'),
        ),
        const SizedBox(height: 14),
        _AuthField(
          label: 'Password',
          controller: _regPass,
          obscure: !_showPassword,
          onToggleObscure: () => setState(() => _showPassword = !_showPassword),
          error: _errors['regPass'],
          textInputAction: TextInputAction.next,
          onChanged: (_) => _clearError('regPass'),
        ),
        const SizedBox(height: 14),
        _AuthField(
          label: 'Ulangi password',
          controller: _regConfirm,
          obscure: !_showPassword,
          error: _errors['regConfirm'],
          onChanged: (_) => _clearError('regConfirm'),
          onSubmitted: (_) => _submitRegister(),
        ),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'Daftar',
          loading: _loading,
          onPressed: _submitRegister,
        ),
        const SizedBox(height: 16),
        _footer(
          'Sudah punya akun?',
          'Masuk',
          () => _setMode(_AuthMode.login),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // FORM: LUPA PASSWORD
  // ----------------------------------------------------------

  Widget _buildForgotForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          'Atur ulang password',
          'Masukkan email akunmu. Kami akan mengirim link untuk membuat password baru.',
        ),
        _AuthField(
          label: 'Email',
          controller: _forgotEmail,
          hint: 'nama@email.com',
          keyboardType: TextInputType.emailAddress,
          error: _errors['forgotEmail'],
          onChanged: (_) => _clearError('forgotEmail'),
          onSubmitted: (_) => _submitForgot(),
        ),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'Kirim link reset',
          loading: _loading,
          onPressed: _submitForgot,
        ),
        const SizedBox(height: 16),
        _footer('Ingat passwordmu?', 'Kembali masuk', () {
          _setMode(_AuthMode.login);
        }),
      ],
    );
  }

  // ----------------------------------------------------------
  // BAGIAN KECIL
  // ----------------------------------------------------------

  Widget _header(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticeBox() {
    if (_notice == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x224A6FC3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x664A6FC3)),
      ),
      child: Text(
        _notice!,
        style: const TextStyle(
          color: AppColors.lightBlue,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _linkButton(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.lightBlue, fontSize: 13),
      ),
    );
  }

  Widget _footer(String text, String linkText, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(color: AppColors.mutedText, fontSize: 13),
        ),
        const SizedBox(width: 2),
        _linkButton(linkText, onTap),
      ],
    );
  }
}

// ============================================================
// KOLOM INPUT (label di atas, garis biru saat aktif, error di bawah)
// ============================================================

class _AuthField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? error;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _AuthField({
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null;

    final borderColor = hasError
        ? AppColors.danger
        : _focused
        ? AppColors.blue
        : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: _focused ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscure,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF55555A),
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              if (widget.onToggleObscure != null)
                TextButton(
                  onPressed: widget.onToggleObscure,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    widget.obscure ? 'Show' : 'Hide',
                    style: const TextStyle(
                      color: AppColors.lightBlue,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    widget.error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? const Color(0x224A6FC3) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.blue : AppColors.border,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.lightBlue : AppColors.softText,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TOMBOL UTAMA (berubah teks saat memproses)
// ============================================================

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0x994A6FC3),
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            loading ? 'Memproses...' : label,
            key: ValueKey(loading),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

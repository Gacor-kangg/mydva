
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/user_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color bg = Color(0xFF0B0B0C);
  static const Color panel = Color(0xFF151516);
  static const Color border = Color(0xFF2A2A2D);
  static const Color blue = Color(0xFF9DBEFF);
  static const Color muted = Color(0xFF8E8E93);

  final _service = UserService();
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _picker = ImagePicker();
  bool _loading = true;
  bool _saving = false;
  String? _photoUrl;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await _service.getCurrentProfile();
      if (!mounted) return;
      _name.text = (data['username'] ?? '').toString();
      _bio.text = (data['bio'] ?? '').toString();
      _email.text = (data['email'] ?? '').toString();
      setState(() { _photoUrl = data['photoUrl']?.toString(); _loading = false; });
    } catch (e) { if (mounted) { setState(() => _loading = false); _message('Gagal memuat profil: $e'); } }
  }

  Future<void> _pickPhoto() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200);
    if (image == null) return;

    final extension = image.name.split('.').last.toLowerCase();
    if (!{'jpg', 'jpeg', 'png'}.contains(extension)) {
      _message('Format foto harus JPG, JPEG, atau PNG.');
      return;
    }

    setState(() => _saving = true);
    try {
      final bytes = await image.readAsBytes();
      final url = await _service.uploadProfilePhoto(
        bytes,
        fileName: image.name,
      );
      if (mounted) { setState(() => _photoUrl = url); _message('Foto profil berhasil diperbarui.'); }
    } catch (e) { if (mounted) _message('Gagal mengunggah foto: $e'); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _removePhoto() async {
    if (_photoUrl == null || _photoUrl!.isEmpty) return;
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: panel, title: const Text('Hapus foto profil?', style: TextStyle(color: Colors.white)),
      content: const Text('Foto profil akan dihapus.', style: TextStyle(color: Colors.white70)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus'))],
    ));
    if (yes != true) return;
    setState(() => _saving = true);
    try { await _service.removeProfilePhoto(); if (mounted) { setState(() => _photoUrl = null); _message('Foto profil dihapus.'); } }
    catch (e) { if (mounted) _message('Gagal menghapus foto: $e'); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _saveProfile() async {
    if (_name.text.trim().isEmpty) { _message('Username wajib diisi.'); return; }
    setState(() => _saving = true);
    try {
      await _service.updateProfile(username: _name.text, bio: _bio.text);
      if (mounted) _message('Profil berhasil disimpan.');
    } catch (e) { if (mounted) _message('Gagal menyimpan profil: $e'); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _changeEmail() async {
    final newEmail = _email.text.trim();
    if (newEmail.isEmpty) { _message('Masukkan email baru.'); return; }
    final password = await showDialog<String>(context: context, builder: (ctx) {
      final controller = TextEditingController();
      return AlertDialog(backgroundColor: panel,
        title: const Text('Konfirmasi identitas', style: TextStyle(color: Colors.white)),
        content: TextField(controller: controller, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Password saat ini', labelStyle: TextStyle(color: muted))),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')), TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Lanjutkan'))],
      );
    });
    if (password == null || password.isEmpty) return;
    setState(() => _saving = true);
    try {
      await _service.changeEmail(newEmail: newEmail, currentPassword: password);
      if (mounted) _message('Link verifikasi telah dikirim ke $newEmail. Email akan berubah setelah diverifikasi.');
    } on FirebaseAuthException catch (e) {
      if (mounted) _message(e.code == 'wrong-password' || e.code == 'invalid-credential' ? 'Password saat ini salah.' : (e.message ?? 'Gagal mengganti email.'));
    } catch (e) { if (mounted) _message('Gagal mengganti email: $e'); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  void _message(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));

  @override
  void dispose() { _name.dispose(); _bio.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bg,
    appBar: AppBar(backgroundColor: bg, foregroundColor: Colors.white, title: const Text('SETTINGS', style: TextStyle(fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.w700)),),
    body: _loading ? const Center(child: CircularProgressIndicator()) : Center(
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: ListView(padding: const EdgeInsets.all(20), children: [
        _section('PROFILE PHOTO', Column(children: [
          CircleAvatar(radius: 52, backgroundColor: const Color(0xFF202024), backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty ? NetworkImage(_photoUrl!) : null,
            child: _photoUrl == null || _photoUrl!.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 48) : null),
          const SizedBox(height: 14), Wrap(spacing: 10, children: [
            OutlinedButton.icon(onPressed: _saving ? null : _pickPhoto, icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Tambah / Ganti foto')),
            TextButton.icon(onPressed: _saving || _photoUrl == null ? null : _removePhoto, icon: const Icon(Icons.delete_outline), label: const Text('Hapus foto')),
          ]),
        ])),
        const SizedBox(height: 16),
        _section('PROFILE INFORMATION', Column(children: [
          _field('Username', _name, maxLength: 30), const SizedBox(height: 14),
          _field('About', _bio, maxLength: 160, maxLines: 4), const SizedBox(height: 16),
          Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: _saving ? null : _saveProfile, child: const Text('Save profile'))),
        ])),
        const SizedBox(height: 16),
        _section('EMAIL ADDRESS', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _field('Email baru', _email, keyboardType: TextInputType.emailAddress), const SizedBox(height: 8),
          const Text('Kami akan mengirim link verifikasi ke alamat email baru. Perubahan berlaku setelah email diverifikasi.', style: TextStyle(color: muted, fontSize: 12, height: 1.5)),
          const SizedBox(height: 14), Align(alignment: Alignment.centerRight, child: FilledButton.tonal(onPressed: _saving ? null : _changeEmail, child: const Text('Ganti email'))),
        ])),
        if (_saving) const Padding(padding: EdgeInsets.only(top: 18), child: LinearProgressIndicator()),
      ])),
    ),
  );

  Widget _section(String title, Widget child) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: panel, border: Border.all(color: border), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: muted, fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w700)), const SizedBox(height: 18), child]));

  Widget _field(String label, TextEditingController controller, {int? maxLength, int maxLines = 1, TextInputType? keyboardType}) => TextField(
    controller: controller, maxLength: maxLength, maxLines: maxLines, keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white), cursorColor: blue,
    decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: muted), filled: true, fillColor: const Color(0xFF101011), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: blue))),
  );
}

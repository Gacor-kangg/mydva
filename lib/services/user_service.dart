import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';

/// Membaca dan memperbarui profil pengguna pada Firebase Auth + Firestore.
class UserService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const String fallbackUsername = 'Pengguna MYDVAN';
  String? get currentUid => _auth.currentUser?.uid;

  Future<Map<String, dynamic>> getCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return {'username': fallbackUsername, 'bio': ''};
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final data = snapshot.data() ?? <String, dynamic>{};
    final emailName = user.email != null && user.email!.contains('@') ? user.email!.split('@').first : fallbackUsername;
    return {
      ...data,
      'uid': user.uid,
      'username': _nonEmpty(data['username']) ?? _nonEmpty(user.displayName) ?? emailName,
      'email': user.email ?? data['email'],
      'photoUrl': user.photoURL ?? data['photoUrl'],
      'bio': data['bio']?.toString() ?? '',
    };
  }

  Future<String> getCurrentUsername() async => (await getCurrentProfile())['username']?.toString() ?? fallbackUsername;

  Future<void> updateProfile({required String username, required String bio}) async {
    final user = _requireUser();
    final cleanName = username.trim();
    if (cleanName.isEmpty) throw ArgumentError('Username tidak boleh kosong.');
    await user.updateDisplayName(cleanName);
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid, 'username': cleanName, 'email': user.email,
      'photoUrl': user.photoURL, 'bio': bio.trim(), 'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await user.reload();
  }

  Future<String> uploadProfilePhoto(
    Uint8List bytes, {
    required String fileName,
  }) async {
    final user = _requireUser();
    if (bytes.isEmpty) throw Exception('File foto kosong.');

    // Validasi format dilakukan di aplikasi karena preset Cloudinary tidak
    // menyediakan pembatasan format pada konfigurasi yang digunakan.
    final extension = fileName.split('.').last.toLowerCase();
    if (!{'jpg', 'jpeg', 'png'}.contains(extension)) {
      throw Exception('Format foto harus JPG, JPEG, atau PNG.');
    }

    final isJpeg = bytes.length >= 3 &&
        bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
    final isPng = bytes.length >= 8 &&
        bytes[0] == 0x89 && bytes[1] == 0x50 &&
        bytes[2] == 0x4E && bytes[3] == 0x47 &&
        bytes[4] == 0x0D && bytes[5] == 0x0A &&
        bytes[6] == 0x1A && bytes[7] == 0x0A;
    if (!isJpeg && !isPng) {
      throw Exception('Isi file bukan gambar JPG/JPEG atau PNG yang valid.');
    }
    if (bytes.length > 5 * 1024 * 1024) {
      throw Exception('Ukuran foto maksimal 5 MB.');
    }
    if (CloudinaryConfig.cloudName == 'ISI_CLOUD_NAME' ||
        CloudinaryConfig.uploadPreset == 'ISI_UNSIGNED_PRESET') {
      throw Exception('Konfigurasi Cloudinary belum diisi.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$extension',
      ));

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );
    final response = await http.Response.fromStream(streamedResponse);
    final Map<String, dynamic> result = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = result['error'] is Map
          ? result['error']['message']?.toString()
          : null;
      throw Exception(message ?? 'Cloudinary gagal mengunggah foto (${response.statusCode}).');
    }

    final url = result['secure_url']?.toString();
    if (url == null || url.isEmpty) {
      throw Exception('Cloudinary tidak mengembalikan URL foto.');
    }

    await user.updatePhotoURL(url);
    await _firestore.collection('users').doc(user.uid).set({
      'photoUrl': url,
      'photoProvider': 'cloudinary',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await user.reload();
    return url;
  }

  Future<void> removeProfilePhoto() async {
    final user = _requireUser();
    // Unsigned upload tidak memiliki izin untuk menghapus aset Cloudinary.
    // Hapus referensinya dari profil; file lama tetap berada di Cloudinary.
    await user.updatePhotoURL(null);
    await _firestore.collection('users').doc(user.uid).set({
      'photoUrl': FieldValue.delete(),
      'photoProvider': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await user.reload();
  }

  Future<void> changeEmail({required String newEmail, required String currentPassword}) async {
    final user = _requireUser();
    final email = newEmail.trim();
    if (email.isEmpty || !email.contains('@')) throw ArgumentError('Alamat email tidak valid.');
    final hasPasswordProvider = user.providerData.any((p) => p.providerId == 'password');
    if (!hasPasswordProvider) {
      throw FirebaseAuthException(code: 'reauthentication-required', message: 'Akun ini tidak menggunakan login email/password. Silakan login ulang dengan penyedia akun sebelum mengganti email.');
    }
    final credential = EmailAuthProvider.credential(email: user.email ?? '', password: currentPassword);
    await user.reauthenticateWithCredential(credential);
    await user.verifyBeforeUpdateEmail(email);
    await _firestore.collection('users').doc(user.uid).set({
      'pendingEmail': email, 'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  User _requireUser() => _auth.currentUser ?? (throw FirebaseAuthException(code: 'not-signed-in', message: 'Silakan login terlebih dahulu.'));
  String? _nonEmpty(dynamic value) => value is String && value.trim().isNotEmpty ? value.trim() : null;
}

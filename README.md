# MYDVA

**MYDVA** adalah aplikasi berbasis Flutter yang dirancang untuk membantu pengguna menemukan, menjelajahi, dan mengelola daftar tontonan film, series, anime, J-Drama, dan K-Drama. Aplikasi ini menyediakan informasi media, rating, sinopsis, serta fitur pengelolaan My List dalam satu platform.

##  Fitur Utama

- **Authentication** — Registrasi dan login pengguna menggunakan Firebase Authentication.
- **Media Discovery** — Menjelajahi berbagai informasi film dan serial dari API eksternal.
- **Kategori Media** — Menampilkan lima kategori terpisah: Film, Series, J-Drama, K-Drama, dan Anime.
- **Media Detail** — Menampilkan poster, sinopsis, informasi pemeran, genre, dan rating.
- **My List** — Menyimpan dan mengelola daftar media berdasarkan status tontonan.
- **Profile** — Mengelola informasi profil dan foto pengguna.
- **Recent Activity** — Menampilkan aktivitas media terbaru pengguna.
- **Media Rating** — Memberikan penilaian terhadap media.
- **Feedback** — Menyediakan fitur ulasan dan interaksi pengguna.
- **Poster Zoom** — Memperbesar poster media melalui fitur Photo View.
- **Share Media** — Membagikan informasi media melalui fitur Share Plus.
- **Animations** — Memberikan pengalaman antarmuka yang lebih interaktif menggunakan Flutter Animate.

##  Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework pengembangan aplikasi |
| Dart | Bahasa pemrograman |
| Firebase Authentication | Autentikasi pengguna |
| Cloud Firestore | Penyimpanan data pengguna dan My List |
| Cloudinary | Penyimpanan foto profil |
| TMDB API | Data film dan series |
| AniList API | Data anime |
| Kitsu API | Sumber alternatif data anime |
| Cached Network Image | Pemuatan gambar dari URL |
| Flutter Animate | Animasi antarmuka |
| Photo View | Zoom gambar poster |
| Share Plus | Berbagi informasi media |
| Shimer| Animasi Pemuatan gambar  |

## 🏗️ Arsitektur Proyek

MYDVA menggunakan pendekatan arsitektur MVC yang dipisahkan dengan lapisan Repository dan Service untuk mengelola alur data aplikasi.

```text
lib/
├── config/
│   ├── api_config.dart
│   └── cloudinary_config.dart
│
├── controllers/
│   ├── auth_controller.dart
│   ├── media_controller.dart
│   ├── media_detail_controller.dart
│   ├── my_list_controller.dart
│   └── media_feedback_controller.dart
│
├── models/
│
├── repositories/
│
├── services/
│   ├── auth_service.dart
│   ├── tmdb_service.dart
│   ├── anilist_service.dart
│   ├── kitsu_service.dart
│   ├── my_list_service.dart
│   └── user_service.dart
│
└── view/
    ├── home_page.dart
    ├── login_page.dart
    ├── media_listpage.dart
    ├── media_detail_page.dart
    ├── profile_page.dart
    ├── settings_page.dart
    ├── my_list_history_page.dart
    └── ...
```

## 🚀 Instalasi dan Menjalankan Proyek

### 1. Persyaratan

Pastikan perangkat telah memiliki:
- Flutter SDK
- Dart SDK
- Android Studio atau Visual Studio Code
- Git
- Browser Chrome atau emulator untuk menjalankan aplikasi

### 2. Clone Repository

```bash
git clone https://github.com/Gacor-kangg/mydva.git
```

Masuk ke direktori proyek:

```bash
cd mydva
```

### 3. Instalasi Dependencies

```bash
flutter pub get
```

### 4. Konfigurasi Firebase

Siapkan proyek Firebase dan hubungkan aplikasi Flutter menggunakan FlutterFire CLI.

Pastikan konfigurasi Firebase tersedia, termasuk file `firebase_options.dart`, serta layanan Authentication dan Cloud Firestore telah diaktifkan.

### 5. Konfigurasi API dan Cloudinary

Sesuaikan konfigurasi API pada:

```text
lib/config/api_config.dart
lib/config/cloudinary_config.dart
```

Masukkan kredensial API dan konfigurasi Cloudinary sesuai akun yang digunakan.

Jangan memasukkan API Secret atau kredensial privat ke repository publik.

### 6. Menjalankan Aplikasi

Untuk menjalankan aplikasi pada Chrome:

```bash
flutter run -d chrome
```

Untuk menjalankan pada perangkat Android:

```bash
flutter run
```

## 📂 Sumber Data

MYDVA memanfaatkan beberapa sumber data eksternal:

- **TMDB** — Informasi film dan series.
- **AniList** — Informasi anime.
- **Kitsu** — Sumber alternatif informasi anime.

Data pengguna seperti profil dan daftar tontonan dikelola melalui layanan Firebase.

## 📌 Catatan Pengembangan

- Aplikasi dikembangkan menggunakan Flutter dan Dart.
- Data media diperoleh melalui API eksternal.
- Data My List dan profil pengguna disimpan menggunakan Firebase.
- Foto profil menggunakan Cloudinary.
- Ketersediaan informasi media bergantung pada sumber API yang digunakan.
- Beberapa fitur mungkin memerlukan konfigurasi layanan eksternal sebelum dapat digunakan.

## 👨‍💻 Pengembangan

MYDVA merupakan proyek pengembangan aplikasi berbasis Flutter yang berfokus pada pengelolaan informasi media dan daftar tontonan pengguna.

---

**MYDVA — Discover, Track, and Manage Your Favorite Media.**

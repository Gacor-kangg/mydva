class MediaModel {
  // 1. Atribut final (Otomatis aman / read-only & sudah punya getter bawaan)
  final String title;
  final String imageUrl;
  final String? genre;
  final int? releaseYear;

  // 2. Constructor singkat menggunakan Initializing Formals (this.variabel)
  MediaModel({
    required this.title,
    required this.imageUrl,
    this.genre,
    this.releaseYear,
  });

  // 3. Method / Function PBO
  String getDisplayTitle() {
    if (releaseYear != null) {
      return '$title ($releaseYear)';
    }
    return title;
  }
}
class MediaDetailModel {
  final String? synopsis;
  final Map<String, String> information;
  final List<MediaCastMember> cast;

  const MediaDetailModel({
    this.synopsis,
    this.information = const {},
    this.cast = const [],
  });
}

class MediaCastMember {
  final String name;
  final String role;
  final String? imageUrl;
  final String? secondaryName;
  final String? secondaryRole;
  final String? secondaryImageUrl;

  const MediaCastMember({
    required this.name,
    required this.role,
    this.imageUrl,
    this.secondaryName,
    this.secondaryRole,
    this.secondaryImageUrl,
  });
}

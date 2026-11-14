import '../services/user_service.dart';

class UserRepository {
  final UserService _service;

  UserRepository({required UserService service}) : _service = service;

  String? get currentUid => _service.currentUid;

  Future<String> getCurrentUsername() => _service.getCurrentUsername();

  Future<Map<String, dynamic>> getCurrentProfile() =>
      _service.getCurrentProfile();

  Future<void> updateProfile({required String username, required String bio}) =>
      _service.updateProfile(username: username, bio: bio);
}

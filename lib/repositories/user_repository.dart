import '../services/user_service.dart';

class UserRepository {
  final UserService _service;

  UserRepository({required UserService service}) : _service = service;

  String? get currentUid => _service.currentUid;

  Future<String> getCurrentUsername() => _service.getCurrentUsername();
}

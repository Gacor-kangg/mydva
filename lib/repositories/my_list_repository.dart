import '../models/my_list_entry.dart';
import '../models/media_model.dart';
import '../services/my_list_service.dart';

class MyListRepository {
  final MyListService _service;

  MyListRepository({required MyListService service}) : _service = service;

  Future<MyListEntry?> getEntry(MediaModel media) =>
      _service.get(media.mediaKey);

  Future<void> saveEntry(MyListEntry entry) => _service.save(entry);

  Future<void> removeEntry(MediaModel media) => _service.remove(media.mediaKey);

  Stream<List<MyListEntry>> watchAll() => _service.watchAll();
}

import '../models/media_detail_model.dart';
import '../models/media_model.dart';
import '../services/media_detail_service.dart';

class MediaDetailController {
  final MediaDetailService _service;
  MediaDetailController({MediaDetailService? service})
      : _service = service ?? MediaDetailService();

  Future<MediaDetailModel> load(MediaModel media) => _service.getDetail(media);
  void dispose() => _service.dispose();
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/media_feedback_service.dart';

class MediaFeedbackRepository {
  final MediaFeedbackService _service;
  MediaFeedbackRepository({required MediaFeedbackService service})
    : _service = service;

  Stream<QuerySnapshot<Map<String, dynamic>>> reviews(String key) =>
      _service.reviews(key);
  Stream<QuerySnapshot<Map<String, dynamic>>> discussions(String key) =>
      _service.discussions(key);
  Stream<QuerySnapshot<Map<String, dynamic>>> replies(
    String key,
    String discussionId,
  ) => _service.replies(key, discussionId);

  Future<void> addReview({
    required String mediaKey,
    required String uid,
    required String username,
    required String text,
    required bool spoiler,
    int? score,
  }) => _service.addReview(
    mediaKey: mediaKey,
    uid: uid,
    username: username,
    text: text,
    spoiler: spoiler,
    score: score,
  );

  Future<void> updateReview({
    required String mediaKey,
    required String reviewId,
    required String text,
    required bool spoiler,
    int? score,
  }) => _service.updateReview(
    mediaKey: mediaKey,
    reviewId: reviewId,
    text: text,
    spoiler: spoiler,
    score: score,
  );

  Future<void> deleteReview({
    required String mediaKey,
    required String reviewId,
  }) => _service.deleteReview(mediaKey: mediaKey, reviewId: reviewId);

  Future<void> toggleHelpful({
    required String mediaKey,
    required String reviewId,
    required String uid,
  }) =>
      _service.toggleHelpful(mediaKey: mediaKey, reviewId: reviewId, uid: uid);

  Future<void> addDiscussion({
    required String mediaKey,
    required String uid,
    required String username,
    required String text,
  }) => _service.addDiscussion(
    mediaKey: mediaKey,
    uid: uid,
    username: username,
    text: text,
  );

  Future<void> updateDiscussion({
    required String mediaKey,
    required String discussionId,
    required String text,
  }) => _service.updateDiscussion(
    mediaKey: mediaKey,
    discussionId: discussionId,
    text: text,
  );

  Future<void> deleteDiscussion({
    required String mediaKey,
    required String discussionId,
  }) =>
      _service.deleteDiscussion(mediaKey: mediaKey, discussionId: discussionId);

  Future<void> addReply({
    required String mediaKey,
    required String discussionId,
    required String uid,
    required String username,
    required String text,
  }) => _service.addReply(
    mediaKey: mediaKey,
    discussionId: discussionId,
    uid: uid,
    username: username,
    text: text,
  );

  Future<void> updateReply({
    required String mediaKey,
    required String discussionId,
    required String replyId,
    required String text,
  }) => _service.updateReply(
    mediaKey: mediaKey,
    discussionId: discussionId,
    replyId: replyId,
    text: text,
  );

  Future<void> deleteReply({
    required String mediaKey,
    required String discussionId,
    required String replyId,
  }) => _service.deleteReply(
    mediaKey: mediaKey,
    discussionId: discussionId,
    replyId: replyId,
  );

  Future<void> updateMyReviewScore({
    required String mediaKey,
    required String uid,
    required int? score,
  }) {
    return _service.updateMyReviewScore(
      mediaKey: mediaKey,
      uid: uid,
      score: score,
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ratings(String key) =>
      _service.ratings(key);

  Future<void> setMyRating({
    required String mediaKey,
    required String uid,
    required int? score,
  }) =>
      _service.setMyRating(
        mediaKey: mediaKey,
        uid: uid,
        score: score,
      );

}

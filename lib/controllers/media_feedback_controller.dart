import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/media_feedback_repository.dart';

class MediaFeedbackController {
  final MediaFeedbackRepository _repository;
  MediaFeedbackController({required MediaFeedbackRepository repository})
    : _repository = repository;

  Stream<QuerySnapshot<Map<String, dynamic>>> reviews(String mediaKey) =>
      _repository.reviews(mediaKey);
  Stream<QuerySnapshot<Map<String, dynamic>>> discussions(String mediaKey) =>
      _repository.discussions(mediaKey);
  Stream<QuerySnapshot<Map<String, dynamic>>> replies(
    String mediaKey,
    String discussionId,
  ) => _repository.replies(mediaKey, discussionId);

  Future<void> addReview({
    required String mediaKey,
    required String uid,
    required String username,
    required String text,
    required bool spoiler,
    int? score,
  }) => _repository.addReview(
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
  }) => _repository.updateReview(
    mediaKey: mediaKey,
    reviewId: reviewId,
    text: text,
    spoiler: spoiler,
    score: score,
  );

  Future<void> deleteReview({
    required String mediaKey,
    required String reviewId,
  }) => _repository.deleteReview(mediaKey: mediaKey, reviewId: reviewId);

  Future<void> toggleHelpful({
    required String mediaKey,
    required String reviewId,
    required String uid,
  }) => _repository.toggleHelpful(
    mediaKey: mediaKey,
    reviewId: reviewId,
    uid: uid,
  );

  Future<void> addDiscussion({
    required String mediaKey,
    required String uid,
    required String username,
    required String text,
  }) => _repository.addDiscussion(
    mediaKey: mediaKey,
    uid: uid,
    username: username,
    text: text,
  );

  Future<void> updateDiscussion({
    required String mediaKey,
    required String discussionId,
    required String text,
  }) => _repository.updateDiscussion(
    mediaKey: mediaKey,
    discussionId: discussionId,
    text: text,
  );

  Future<void> deleteDiscussion({
    required String mediaKey,
    required String discussionId,
  }) => _repository.deleteDiscussion(
    mediaKey: mediaKey,
    discussionId: discussionId,
  );

  Future<void> addReply({
    required String mediaKey,
    required String discussionId,
    required String uid,
    required String username,
    required String text,
  }) => _repository.addReply(
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
  }) => _repository.updateReply(
    mediaKey: mediaKey,
    discussionId: discussionId,
    replyId: replyId,
    text: text,
  );

  Future<void> deleteReply({
    required String mediaKey,
    required String discussionId,
    required String replyId,
  }) => _repository.deleteReply(
    mediaKey: mediaKey,
    discussionId: discussionId,
    replyId: replyId,
  );

  Future<void> updateMyReviewScore({
    required String mediaKey,
    required String uid,
    required int? score,
  }) {
    return _repository.updateMyReviewScore(
      mediaKey: mediaKey,
      uid: uid,
      score: score,
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ratings(String mediaKey) =>
      _repository.ratings(mediaKey);

  Future<void> setMyRating({
    required String mediaKey,
    required String uid,
    required int? score,
  }) =>
      _repository.setMyRating(
        mediaKey: mediaKey,
        uid: uid,
        score: score,
      );

}

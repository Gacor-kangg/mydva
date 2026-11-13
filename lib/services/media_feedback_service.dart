import 'package:cloud_firestore/cloud_firestore.dart';

class MediaFeedbackService {
  final FirebaseFirestore _db;
  MediaFeedbackService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(
    String mediaKey,
    String type,
  ) => _db.collection('media_feedback').doc(mediaKey).collection(type);

  Stream<QuerySnapshot<Map<String, dynamic>>> reviews(String mediaKey) =>
      _collection(
        mediaKey,
        'reviews',
      ).orderBy('createdAt', descending: true).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> discussions(String mediaKey) =>
      _collection(
        mediaKey,
        'discussions',
      ).orderBy('createdAt', descending: true).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> replies(
    String mediaKey,
    String discussionId,
  ) => _collection(
    mediaKey,
    'discussions',
  ).doc(discussionId).collection('replies').orderBy('createdAt').snapshots();

  Future<void> addReview({
    required String mediaKey,
    required String uid,
    required String username,
    required String text,
    required bool spoiler,
    int? score,
  }) async {
    await _collection(mediaKey, 'reviews').add({
      'uid': uid,
      'username': username,
      'text': text,
      'spoiler': spoiler,
      'score': score,
      'helpfulBy': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateReview({
    required String mediaKey,
    required String reviewId,
    required String text,
    required bool spoiler,
    int? score,
  }) async {
    await _collection(mediaKey, 'reviews').doc(reviewId).update({
      'text': text,
      'spoiler': spoiler,
      'score': score,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteReview({
    required String mediaKey,
    required String reviewId,
  }) => _collection(mediaKey, 'reviews').doc(reviewId).delete();

  Future<void> toggleHelpful({
    required String mediaKey,
    required String reviewId,
    required String uid,
  }) async {
    final ref = _collection(mediaKey, 'reviews').doc(reviewId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data() ?? {};
      final users = List<String>.from(data['helpfulBy'] ?? const <String>[]);
      if (users.contains(uid)) {
        users.remove(uid);
      } else {
        users.add(uid);
      }
      tx.update(ref, {'helpfulBy': users});
    });
  }

  Future<void> addDiscussion({
    required String mediaKey,
    required String uid,
    required String username,
    required String text,
  }) async {
    await _collection(mediaKey, 'discussions').add({
      'uid': uid,
      'username': username,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDiscussion({
    required String mediaKey,
    required String discussionId,
    required String text,
  }) async {
    await _collection(mediaKey, 'discussions').doc(discussionId).update({
      'text': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDiscussion({
    required String mediaKey,
    required String discussionId,
  }) async {
    final discussionRef = _collection(
      mediaKey,
      'discussions',
    ).doc(discussionId);
    final replies = await discussionRef.collection('replies').get();
    final batch = _db.batch();
    for (final reply in replies.docs) {
      batch.delete(reply.reference);
    }
    batch.delete(discussionRef);
    await batch.commit();
  }

  Future<void> addReply({
    required String mediaKey,
    required String discussionId,
    required String uid,
    required String username,
    required String text,
  }) async {
    await _collection(
      mediaKey,
      'discussions',
    ).doc(discussionId).collection('replies').add({
      'uid': uid,
      'username': username,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateReply({
    required String mediaKey,
    required String discussionId,
    required String replyId,
    required String text,
  }) async {
    await _collection(mediaKey, 'discussions')
        .doc(discussionId)
        .collection('replies')
        .doc(replyId)
        .update({'text': text, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> deleteReply({
    required String mediaKey,
    required String discussionId,
    required String replyId,
  }) => _collection(
    mediaKey,
    'discussions',
  ).doc(discussionId).collection('replies').doc(replyId).delete();

  Future<void> updateMyReviewScore({
    required String mediaKey,
    required String uid,
    required int? score,
  }) async {
    final query = await _collection(
      mediaKey,
      'reviews',
    ).where('uid', isEqualTo: uid).get();

    if (query.docs.isEmpty) return;

    final batch = _db.batch();

    for (final doc in query.docs) {
      batch.update(doc.reference, {
        'score': score,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ratings(String mediaKey) =>
    _collection(mediaKey, 'ratings').snapshots();

  Future<void> setMyRating({
    required String mediaKey,
    required String uid,
    required int? score,
  }) async {
    final ref = _collection(mediaKey, 'ratings').doc(uid);

    if (score == null) {
      await ref.delete();
      return;
    }

    if (score < 1 || score > 10) {
      throw ArgumentError.value(
        score,
        'score',
        'Score harus 1 sampai 10.',
      );
    }

    await ref.set({
      'uid': uid,
      'score': score,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

}

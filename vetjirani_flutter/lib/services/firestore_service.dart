import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String location,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Future<void> addReview({
    required String vetId,
    required String farmerId,
    required String comment,
    required double rating,
  }) async {
    await _db.collection('reviews').add({
      'vetId': vetId,
      'farmerId': farmerId,
      'comment': comment,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getReviewsForVet(String vetId) {
    return _db
        .collection('reviews')
        .where('vetId', isEqualTo: vetId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

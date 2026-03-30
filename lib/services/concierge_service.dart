import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConciergeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitRequest({
    required String serviceType,
    required String serviceName,
    required Map<String, dynamic> requestDetails,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in to submit requests');

    await _firestore.collection('concierge_requests').add({
      'userId': user.uid,
      'userEmail': user.email,
      'serviceType': serviceType,
      'serviceName': serviceName,
      'requestDetails': requestDetails,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserRequests() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in to view requests');

    return _firestore
        .collection('concierge_requests')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
} 
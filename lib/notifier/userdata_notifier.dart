import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/user_model.dart';

class UserDataNotifier extends Notifier<UserData?> {
  @override
  UserData? build() => null;

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users_passengers')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        state = UserData.fromMap(doc.data()!); // ✅ Now matches the state type
      }
    }
  }

  Future<List?> getNotifiedLocations(String userId) async {
    final docRef =
        FirebaseFirestore.instance.collection('users_passengers').doc(userId);
    final snapshot = await docRef.get();
    return snapshot.data()?['notifyLocation'] as List<dynamic>?;
  }

  Future<void> updateNotifyLocation(
      String userId, String notifyLocation) async {
    await FirebaseFirestore.instance
        .collection('users_passengers')
        .doc(userId)
        .update({'notifyLocation': notifyLocation});
  }

  void clearUserData() {
    state = null;
  }
}

final userProvider = NotifierProvider<UserDataNotifier, UserData?>(
  UserDataNotifier.new,
);

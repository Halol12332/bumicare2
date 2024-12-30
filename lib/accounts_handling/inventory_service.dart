import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<dynamic>> loadInventory() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user is logged in.');

      final userDoc = await _firestore.collection('users').doc(currentUser.email).get();

      if (!userDoc.exists) throw Exception('User document does not exist.');

      final List<dynamic> userInventory = userDoc.data()?['inventory'] ?? [];
      return userInventory;
    } catch (e) {
      throw Exception("Error loading inventory: $e");
    }
  }

  Future<void> useReward(String rewardName) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user is logged in.');

      final userDocRef = _firestore.collection('users').doc(currentUser.email);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) throw Exception('User document does not exist.');

      List<dynamic> updatedInventory = List.from(userDoc.data()?['inventory'] ?? []);
      updatedInventory.remove(rewardName);

      List<dynamic> updatedUsedRewards = List.from(userDoc.data()?['usedRewards'] ?? []);
      updatedUsedRewards.add(rewardName);

      await userDocRef.update({
        'inventory': updatedInventory,
        'usedRewards': updatedUsedRewards,
      });
    } catch (e) {
      throw Exception("Error using reward: $e");
    }
  }
}

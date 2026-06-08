import 'package:cloud_firestore/cloud_firestore.dart';

class UserCollection {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  Future<void> addUser(String uid, Map<String, dynamic> userData) async {
    try {
      await _usersCollection.doc(uid).set(userData);
    } catch (e) {
      throw Exception('Failed to add user to Firestore: $e');
    }
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    try {
      return await _usersCollection.doc(uid).get();
    } catch (e) {
      throw Exception('Failed to get user from Firestore: $e');
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    try {
      await _usersCollection.doc(uid).update(userData);
    } catch (e) {
      throw Exception('Failed to update user in Firestore: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user from Firestore: $e');
    }
  }

  Stream<QuerySnapshot> getUsersStream() {
    return _usersCollection.snapshots();
  }
}

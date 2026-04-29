import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      String uniqueHistoryId = _db.collection('history').doc().id;
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'user_id': user.uid,
          'username': username,
          'email': email,
          'hash_password': password,
          'history_id': uniqueHistoryId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}
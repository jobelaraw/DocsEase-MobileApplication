import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
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
          'profile_img': 'assets/default_profile.png',
          'history_id': uniqueHistoryId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isEmailTaken(String email) async {
    try {
      final querySnapshot = await _db.collection('users').where('email', isEqualTo: email).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateUserProfile({
    String? newUsername,
    String? newPassword,
    String? newProfileImgUrl,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    try {
      // 1. Prepare Firestore Updates (Username and Image)
      Map<String, dynamic> firestoreUpdates = {};

      if (newUsername != null && newUsername.isNotEmpty) {
        firestoreUpdates['username'] = newUsername;
      }
      if (newProfileImgUrl != null && newProfileImgUrl.isNotEmpty) {
        firestoreUpdates['profile_img'] = newProfileImgUrl; // Saves the URL!
      }

      // If there are things to update in Firestore, do it:
      if (firestoreUpdates.isNotEmpty) {
        await _db.collection('users').doc(user.uid).update(firestoreUpdates);
      }

      // 2. Update Password in Firebase Auth (Secure Vault)
      if (newPassword != null && newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // The user canceled the sign-in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // ✨ THE SIGN-UP CHECK: Does this user exist in our Firestore database yet?
        DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // They are a brand new user! Let's set up their profile.
          String uniqueHistoryId = _db.collection('history').doc().id;

          // We will use their Google Display Name as their default username
          String defaultUsername = user.displayName ?? "Google User";

          await _db.collection('users').doc(user.uid).set({
            'user_id': user.uid,
            'username': defaultUsername,
            'email': user.email,
            'profile_img':
                user.photoURL ??
                'assets/default_profile.png', // Use their Google photo if they have one!
            'history_id': uniqueHistoryId,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  Future<void> signOutUser() async {
    try {
      // Wipe the Google Sign-In cache so the account picker shows up next time!
      await GoogleSignIn().signOut();

      // Sign out of Firebase
      await _auth.signOut();
    } catch (e) {
      print("Sign Out Error: $e");
      rethrow;
    }
  }

  Future<String?> uploadProfileImage(File imageFile, String uid) async {
    try {
      // Create a unique file name
      final fileExtension = imageFile.path.split('.').last;
      final fileName = '$uid-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Point to the 'profile_images' folder in Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      // Ask Firebase for the secure download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Firebase Storage Upload Error: $e");
      return null;
    }
  }

  Future<void> deleteOldProfileImage(String oldImageUrl) async {
    try {
      // Safety check to ensure it's actually a Firebase URL
      if (!oldImageUrl.contains('firebasestorage.googleapis.com')) return;

      // Firebase is incredibly smart: it can find and delete the file directly from the URL!
      final Reference storageRef = FirebaseStorage.instance.refFromURL(oldImageUrl);
      await storageRef.delete();

      print("Old image successfully deleted from Firebase Storage!");
    } catch (e) {
      print("Firebase Storage Delete Error: $e");
    }
  }
}

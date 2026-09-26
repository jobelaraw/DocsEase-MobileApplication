import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:docsease/info_model.dart';
import 'package:hive/hive.dart';
import 'dart:io';

// sign in - G account already has profile
class GoogleAccountAlreadyUsedException implements Exception {}

//G account not registered yet
class GoogleAccountNotRegisteredException implements Exception {}

// G account belongs to admin
class GoogleAccountIsAdminException implements Exception {}

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

  Future<bool> isEmailRegistered(String email) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('isEmailRegistered');
      final result = await callable.call({'email': email.trim().toLowerCase()});
      return result.data['exists'] == true;
    } catch (e) {
      print('Error checking registered email: $e');
      rethrow;
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
      Map<String, dynamic> firestoreUpdates = {};

      if (newUsername != null && newUsername.isNotEmpty) {
        firestoreUpdates['username'] = newUsername;
      }
      if (newProfileImgUrl != null && newProfileImgUrl.isNotEmpty) {
        firestoreUpdates['profile_img'] = newProfileImgUrl;
      }

      if (firestoreUpdates.isNotEmpty) {
        await _db.collection('users').doc(user.uid).update(firestoreUpdates);
      }

      if (newPassword != null && newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Returns null if the user dismissed the account picker.
  Future<UserCredential?> _signInWithGoogle() async {
    // google_sign_in's signIn() doesn't return an idToken on web, so use Firebase's popup flow there
    if (kIsWeb) {
      final provider = GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'});
      try {
        return await _auth.signInWithPopup(provider);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') return null;
        rethrow;
      }
    }

    final GoogleSignIn googleSignIn = GoogleSignIn();
    // sign out first so the account picker is always shown
    await googleSignIn.signOut();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential?> signInWithGoogleStrict() async {
    UserCredential? userCredential = await _signInWithGoogle();
    User? user = userCredential?.user;
    if (user == null) return null;

    final adminDoc = await _db.collection('admin').doc(user.uid).get();
    if (adminDoc.exists) {
      await _auth.signOut();
      throw GoogleAccountIsAdminException();
    }

    final userDoc = await _db.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      await _auth.signOut();
      throw GoogleAccountNotRegisteredException();
    }

    return userCredential;
  }

  Future<UserCredential?> signUpWithGoogle() async {
    UserCredential? userCredential = await _signInWithGoogle();
    User? user = userCredential?.user;
    if (user == null) return null;

    final adminDoc = await _db.collection('admin').doc(user.uid).get();
    if (adminDoc.exists) {
      await _auth.signOut();
      throw GoogleAccountIsAdminException();
    }

    final userDoc = await _db.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      await _auth.signOut();
      throw GoogleAccountAlreadyUsedException();
    }

    String uniqueHistoryId = _db.collection('history').doc().id;
    String defaultUsername = user.displayName ?? "Google User";

    await _db.collection('users').doc(user.uid).set({
      'user_id': user.uid,
      'username': defaultUsername,
      'email': user.email,
      'profile_img': user.photoURL ?? 'assets/default_profile.png',
      'history_id': uniqueHistoryId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  Future<void> signOutUser() async {
    try {
      // on web the Google session is managed by Firebase Auth
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();

        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      }
    } catch (e) {
      print("Sign Out Error: $e");
    } finally {
      await _auth.signOut();
    }
  }

  Future<String?> uploadProfileImage(File imageFile, String uid) async {
    try {
      final fileExtension = imageFile.path.split('.').last;
      final fileName = '$uid-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      final Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Firebase Storage Upload Error: $e");
      return null;
    }
  }

  Future<void> deleteOldProfileImage(String oldImageUrl) async {
    try {
      if (!oldImageUrl.contains('firebasestorage.googleapis.com')) return;

      final Reference storageRef = FirebaseStorage.instance.refFromURL(oldImageUrl);
      await storageRef.delete();

      print("Old image successfully deleted from Firebase Storage!");
    } catch (e) {
      print("Firebase Storage Delete Error: $e");
    }
  }

  Future<List<Office>> getOffices() async {
    try {
      QuerySnapshot snapshot = await _db.collection('offices').get();
      List<Office> offices = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> officeData = doc.data() as Map<String, dynamic>;
        officeData['office_id'] = doc.id;

        QuerySnapshot serviceSnapshot = await doc.reference.collection('services').get();

        officeData['services'] = serviceSnapshot.docs.map((sDoc) {
          var sData = sDoc.data() as Map<String, dynamic>;
          sData['service_id'] = sDoc.id;
          return sData;
        }).toList();

        offices.add(Office.fromJson(officeData));
      }

      return offices;
    } catch (e) {
      print("Error fetching offices: $e");
      return [];
    }
  }

  Stream<List<Office>> streamOffices() {
    late StreamController<List<Office>> controller;
    StreamSubscription? officesSub;
    StreamSubscription? servicesSub;

    Map<String, Map<String, dynamic>> officesById = {};
    Map<String, List<Map<String, dynamic>>> servicesByOfficeId = {};
    bool officesLoaded = false;
    bool servicesLoaded = false;

    void emitIfReady() {
      if (!officesLoaded || !servicesLoaded) return;

      final offices = officesById.entries.map((entry) {
        final officeId = entry.key;
        final data = Map<String, dynamic>.from(entry.value);
        data['office_id'] = officeId;
        data['services'] = servicesByOfficeId[officeId] ?? [];
        return Office.fromJson(data);
      }).toList();

      controller.add(offices);
    }

    controller = StreamController<List<Office>>.broadcast(
      onListen: () {
        officesSub = _db.collection('offices').snapshots().listen(
          (snap) {
            officesById = {
              for (var doc in snap.docs) doc.id: doc.data(),
            };
            officesLoaded = true;
            emitIfReady();
          },
          onError: (e) {
            print("Error streaming offices: $e");
            controller.addError(e);
          },
        );

        servicesSub = _db.collectionGroup('services').snapshots().listen(
          (snap) {
            final grouped = <String, List<Map<String, dynamic>>>{};
            for (var doc in snap.docs) {
              final officeId = doc.reference.parent.parent?.id;
              if (officeId == null) continue;
              final data = Map<String, dynamic>.from(doc.data());
              data['service_id'] = doc.id;
              grouped.putIfAbsent(officeId, () => []).add(data);
            }
            servicesByOfficeId = grouped;
            servicesLoaded = true;
            emitIfReady();
          },
          onError: (e) {
            print("Error streaming services: $e");
            controller.addError(e);
          },
        );
      },
      onCancel: () {
        officesSub?.cancel();
        servicesSub?.cancel();
      },
    );

    return controller.stream;
  }

  Future<ServiceDetail?> getServiceById(String serviceId) async {
    try {
      final officesSnap = await _db.collection('offices').get();

      final officeDocs = officesSnap.docs.toList();
      officeDocs.sort((a, b) => b.id.length.compareTo(a.id.length));

      QueryDocumentSnapshot? matchedOffice;
      for (var doc in officeDocs) {
        if (serviceId.startsWith(doc.id)) {
          matchedOffice = doc;
          break;
        }
      }

      if (matchedOffice != null) {
        final serviceDoc = await matchedOffice.reference
            .collection('services')
            .doc(serviceId)
            .get();

        if (serviceDoc.exists) {
          var serviceData = serviceDoc.data() as Map<String, dynamic>;
          serviceData['service_id'] = serviceDoc.id;

          var officeData = matchedOffice.data() as Map<String, dynamic>;
          officeData['office_name'] = officeData['office_name'] ?? 'Unknown Office';
          officeData['location'] = officeData['location'] ?? 'City Hall';
          officeData['contact_phone'] = officeData['contact_phone'] ?? '';
          officeData['contact_email'] = officeData['contact_email'] ?? '';

          return ServiceDetail.fromJson(serviceData, officeData);
        }
      }

      for (var office in officeDocs) {
        final sDoc = await office.reference.collection('services').doc(serviceId).get();
        if (sDoc.exists) {
          var serviceData = sDoc.data() as Map<String, dynamic>;
          serviceData['service_id'] = sDoc.id;

          var officeData = office.data() as Map<String, dynamic>;
          officeData['office_name'] = officeData['office_name'] ?? 'Unknown Office';
          officeData['location'] = officeData['location'] ?? 'City Hall';
          officeData['contact_phone'] = officeData['contact_phone'] ?? '';
          officeData['contact_email'] = officeData['contact_email'] ?? '';

          return ServiceDetail.fromJson(serviceData, officeData);
        }
      }

      return null;
    } catch (e) {
      print("Error fetching specific service: $e");
      return null;
    }
  }

  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    String uid = user.uid;

    try {
      final historySnapshot = await _db.collection('users').doc(uid).collection('service_history').get();
      for (var doc in historySnapshot.docs) {
        await doc.reference.delete();
      }

      final convoSnapshot = await _db.collection('users').doc(uid).collection('conversations').get();
      for (var convoDoc in convoSnapshot.docs) {
        final msgSnapshot = await convoDoc.reference.collection('messages').get();
        for (var msgDoc in msgSnapshot.docs) {
          await msgDoc.reference.delete();
        }
        await convoDoc.reference.delete();
      }

      await _db.collection('users').doc(uid).delete();
      await user.delete();
    } catch (e) {
      rethrow;
    }
  }

  // NOTIFICATION METHODS

  // Streams global notifications sorted by newest first
  Stream<List<AppNotification>> streamNotifications() {
    return _db.collection('notifications').orderBy('timestamp', descending: true).snapshots().map((snap) {
      return snap.docs.map((doc) => AppNotification.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Streams the IDs of notifications the user has already tapped
  Stream<List<String>> streamReadNotifications() async* {
    User? user = _auth.currentUser;
    if (user != null) {
      // Authenticated User: Stream from Firestore array
      yield* _db.collection('users').doc(user.uid).snapshots().map((doc) {
        if (doc.exists && doc.data() != null && doc.data()!.containsKey('read_notifications')) {
          return List<String>.from(doc.data()!['read_notifications']);
        }
        return [];
      });
    } else {
      // Guest User: Stream from local Hive box
      var box = Hive.box('auth_box');
      yield List<String>.from(box.get('guest_read_notifs', defaultValue: []));
      yield* box.watch(key: 'guest_read_notifs').map((event) => List<String>.from(event.value ?? []));
    }
  }

  // Marks a notification as read and hides the blue dot
  Future<void> markNotificationAsRead(String notificationId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'read_notifications': FieldValue.arrayUnion([notificationId])
      });
    } else {
      var box = Hive.box('auth_box');
      List<String> reads = List<String>.from(box.get('guest_read_notifs', defaultValue: []));
      if (!reads.contains(notificationId)) {
        reads.add(notificationId);
        await box.put('guest_read_notifs', reads);
      }
    }
  }
}

// Model for incoming notifications
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String serviceId;
  final DateTime timestamp;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.serviceId,
    required this.timestamp,
  });

  factory AppNotification.fromJson(String id, Map<String, dynamic> json) {
    return AppNotification(
      id: id,
      title: json['title'] ?? 'DocsEase Update',
      body: json['body'] ?? '',
      serviceId: json['service_id'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
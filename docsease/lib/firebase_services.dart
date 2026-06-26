import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:docsease/info_model.dart';
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
      // Prepare Firestore Updates (Username and Image)
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

      // Update Password in Firebase Auth (Secure Vault)
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
        // THE SIGN-UP CHECK: Does this user exist in our Firestore database yet?
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
      final GoogleSignIn googleSignIn = GoogleSignIn();

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (e) {
      print("Sign Out Error: $e");
    } finally {
      await _auth.signOut();
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

  Future<List<Office>> getOffices() async {
    try {
      QuerySnapshot snapshot = await _db.collection('offices').get();
      List<Office> offices = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> officeData = doc.data() as Map<String, dynamic>;
        officeData['office_id'] = doc.id;

        // Fetch the 'services' subcollection specifically for this office
        QuerySnapshot serviceSnapshot = await doc.reference.collection('services').get();

        // Attach the fetched services as a list back into the officeData map
        officeData['services'] = serviceSnapshot.docs.map((sDoc) {
          var sData = sDoc.data() as Map<String, dynamic>;
          sData['service_id'] = sDoc.id;
          return sData;
        }).toList();

        // Parse the fully assembled JSON into our Dart Objects
        offices.add(Office.fromJson(officeData));
      }

      return offices;
    } catch (e) {
      print("Error fetching offices: $e");
      return [];
    }
  }

  Future<ServiceDetail?> getServiceById(String serviceId) async {
    try {
      // Fetch all offices (1 lightweight read, ~25 tiny documents)
      final officesSnap = await _db.collection('offices').get();

      // Sort offices by ID length descending to match longer prefixes first
      final officeDocs = officesSnap.docs.toList();
      officeDocs.sort((a, b) => b.id.length.compareTo(a.id.length));

      // Find the exact office by checking if the serviceId starts with the office ID
      QueryDocumentSnapshot? matchedOffice;
      for (var doc in officeDocs) {
        if (serviceId.startsWith(doc.id)) {
          matchedOffice = doc;
          break;
        }
      }

      // If we found the correct office, fetch the service directly! (1 read)
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

      // SAFEGUARD: If the prefix didn't match perfectly, check manually
      for (var office in officeDocs) {
        final sDoc = await office.reference.collection('services').doc(serviceId).get();
        if (sDoc.exists) {
          var serviceData = sDoc.data() as Map<String, dynamic>;
          serviceData['service_id'] = sDoc.id;

          // ignore: unnecessary_cast
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

  /*Future<void> seedDatabase() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Create a batch worker
    final WriteBatch batch = db.batch();

    // Prepare your massive list of data right here in Dart
    final List<Map<String, dynamic>> officesData = [];

    try {
      print("Starting database upload...");

      // 3. Loop through your data and pack it into the batch
      for (var office in officesData) {
        // Create a reference for the Office document
        DocumentReference officeRef = db.collection('offices').doc(office['office_id']);

        batch.set(officeRef, {
          "office_name": office['office_name'],
          "location": office['location'],
          "schedule": office['schedule'],
          "contact_phone": office['contact_phone'],
          "contact_email": office['contact_email'],
          "created_at": FieldValue.serverTimestamp(),
          "updated_at": FieldValue.serverTimestamp(),
        });

        // Loop through the services for this specific office
        List<dynamic> services = office['services'];
        for (var service in services) {
          // Create a reference for the Service subcollection inside this office
          DocumentReference serviceRef = officeRef
              .collection('services')
              .doc(service['service_id']);

          batch.set(serviceRef, {
            "service_name": service['service_name'],
            "description": service['description'],
            "tabs": service['tabs'], // Saves the whole array of requirements and procedures!
            "created_at": FieldValue.serverTimestamp(),
            "updated_at": FieldValue.serverTimestamp(),
          });
        }
      }

      // Hit the big red button and upload everything at once!
      await batch.commit();
      print("Database successfully populated!");
    } catch (e) {
      print("Upload failed: $e");
    }
  }*/
}

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // Use this to fetch a specific user's data
  static Future<void> testReadUser() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('9yxhyzyF5YKizC6mmGn2')
          .get();

      if (doc.exists) {
        // This is where you'd normally update your UI state
        String username = doc.get('username');
        print("Successfully retrieved user: $username");
      }
    } catch (e) {
      // Still good to keep the error catch for debugging
      print("Firebase Read Error: $e");
    }
  }

// Future Tip: You can add functions here for 'createAccount' or 'submitRequest'
}
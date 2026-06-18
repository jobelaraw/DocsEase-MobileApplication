import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _conversationsRef =>
      _db.collection('users').doc(_uid).collection('conversations');

  /// Create a new conversation, returns the conversation ID
  Future<String?> createConversation(String firstMessage) async {
    if (_uid == null) return null;
    final doc = await _conversationsRef.add({
      'title': firstMessage.length > 50
          ? '${firstMessage.substring(0, 50)}...'
          : firstMessage,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Save a message to a conversation
  Future<void> saveMessage(String convoId, String text, bool isUser) async {
    if (_uid == null) return;
    // Write message and update timestamp in parallel
    _conversationsRef.doc(convoId).collection('messages').add({
      'text': text,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _conversationsRef.doc(convoId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get all conversations ordered by most recent
  Stream<QuerySnapshot> getConversations() {
    if (_uid == null) return const Stream.empty();
    return _conversationsRef.orderBy('updatedAt', descending: true).snapshots();
  }

  /// Get all messages in a conversation
  Future<List<Map<String, dynamic>>> getMessages(String convoId) async {
    if (_uid == null) return [];
    final snap = await _conversationsRef
        .doc(convoId)
        .collection('messages')
        .orderBy('timestamp')
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Get the most recent conversation ID
  Future<String?> getMostRecentConversationId() async {
    if (_uid == null) return null;
    final snap = await _conversationsRef
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }

  /// Delete a conversation
  Future<void> deleteConversation(String convoId) async {
    if (_uid == null) return;
    // Delete all messages first
    final messages =
        await _conversationsRef.doc(convoId).collection('messages').get();
    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
    await _conversationsRef.doc(convoId).delete();
  }

  /// Check if user is logged in
  bool get isLoggedIn => _uid != null;
}

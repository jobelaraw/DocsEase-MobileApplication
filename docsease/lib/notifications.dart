import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// MODEL
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String serviceId;
  final bool isRead;
  final DateTime timestamp;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.serviceId,
    required this.isRead,
    required this.timestamp,
  });

  factory AppNotification.fromJson(String id, Map<String, dynamic> json) {
    return AppNotification(
      id: id,
      title: json['title'] ?? 'DocsEase Update',
      body: json['body'] ?? '',
      serviceId: json['service_id'] ?? '',
      isRead: json['is_read'] ?? false,
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// SERVICE
class NotificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>? get _col {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('notifications');
  }

  // Streams user-specific notifications: unread first, then read.
  // Inside each group the newest comes first.
  Stream<List<AppNotification>> streamNotifications() {
    final col = _col;
    if (col == null) return Stream.value([]);
    return col.orderBy('timestamp', descending: true).snapshots().map((snap) {
      final list = snap.docs
          .map((doc) => AppNotification.fromJson(doc.id, doc.data()))
          .toList();

      list.sort((a, b) {
        if (a.isRead != b.isRead) return a.isRead ? 1 : -1; // unread on top
        return b.timestamp.compareTo(a.timestamp); // newest first
      });

      return list;
    });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _col?.doc(notificationId).update({'is_read': true});
  }

  Future<void> deleteNotification(String notificationId) async {
    await _col?.doc(notificationId).delete();
  }

  // Deletes many at once (Firestore batches max out at 500)
  Future<void> deleteNotifications(List<String> notificationIds) async {
    final col = _col;
    if (col == null || notificationIds.isEmpty) return;

    for (var i = 0; i < notificationIds.length; i += 500) {
      final batch = _db.batch();
      for (final id in notificationIds.skip(i).take(500)) {
        batch.delete(col.doc(id));
      }
      await batch.commit();
    }
  }
}
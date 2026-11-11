import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Push notifications (FCM).
//
// The in-app list at users/{uid}/notifications stays the single source of truth.
// A Cloud Function (sendPushOnNotificationCreated) sends a push whenever a doc is
// created there, carrying `notification_id` in the data payload so a tap can open
// the same notification the bell would.
//
// Device tokens are stored on the user doc as an array: users/{uid}.fcm_tokens
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<StreamSubscription> _subs = [];
  String? _uid;
  String? _token;
  DocumentSnapshot<Map<String, dynamic>>? _lastUserDoc;

  // Web needs a VAPID key and a service worker; not set up, so push is mobile only.
  bool get _supported => !kIsWeb;

  /// Call once a registered (non-guest) user is in the app.
  /// [onOpened] receives the notification doc id when the user taps a push.
  /// [onForeground] receives pushes that arrive while the app is open
  /// (Android does not display those by itself).
  Future<void> init({
    required void Function(String notificationId) onOpened,
    void Function(RemoteMessage message)? onForeground,
  }) async {
    if (!_supported) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _cancelSubs();
    _uid = user.uid;

    try {
      // Android 13+ / iOS show the system permission prompt here (only the first time).
      final settings = await _messaging.requestPermission();
      final denied = settings.authorizationStatus == AuthorizationStatus.denied;

      if (!denied) {
        _token = await _messaging.getToken();
        _subs.add(_messaging.onTokenRefresh.listen((t) {
          _token = t;
          _syncToken(_lastUserDoc);
        }));
        // Only write the token once the user doc exists. Never create it here:
        // Google sign-in treats "doc exists" as "account is registered", and
        // sign-up writes the doc with a plain set() that would wipe the field.
        // Watching the doc also re-adds the token if sign-up overwrote it.
        _subs.add(_db.collection('users').doc(user.uid).snapshots().listen(
          _syncToken,
          onError: (e) => debugPrint('Push token sync error: $e'),
        ));
      }

      void open(RemoteMessage m) {
        final id = m.data['notification_id'];
        if (id is String && id.isNotEmpty) onOpened(id);
      }

      // Tapped while the app was in the background
      _subs.add(FirebaseMessaging.onMessageOpenedApp.listen(open));

      // Received while the app is in the foreground
      if (onForeground != null) {
        _subs.add(FirebaseMessaging.onMessage.listen(onForeground));
      }

      // Tapped while the app was fully closed
      final initial = await _messaging.getInitialMessage();
      if (initial != null) open(initial);
    } catch (e) {
      debugPrint('Push init error: $e');
    }
  }

  /// Call BEFORE signing out, while the user can still write to their own doc,
  /// so this device stops receiving the previous account's pushes.
  Future<void> unregister() async {
    if (!_supported) return;
    await _cancelSubs();
    final uid = _uid ?? FirebaseAuth.instance.currentUser?.uid;
    _uid = null;
    _token = null;
    try {
      final token = await _messaging.getToken();
      if (uid != null && token != null) {
        await _db.collection('users').doc(uid).update({
          'fcm_tokens': FieldValue.arrayRemove([token]),
        });
      }
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Push unregister error: $e');
    }
  }

  void _syncToken(DocumentSnapshot<Map<String, dynamic>>? doc) {
    _lastUserDoc = doc;
    final token = _token;
    if (doc == null || !doc.exists || token == null) return;
    final tokens = List<String>.from(doc.data()?['fcm_tokens'] ?? const []);
    if (tokens.contains(token)) return;
    doc.reference
        .update({'fcm_tokens': FieldValue.arrayUnion([token])})
        .catchError((e) => debugPrint('Push token save error: $e'));
  }

  Future<void> _cancelSubs() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _lastUserDoc = null;
  }
}

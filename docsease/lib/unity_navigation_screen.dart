import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

/// Turns an office or room name (the step's navigate_to) into its map_slot, e.g. "s13".
/// Falls back to the name, which Unity can also match.
Future<String> resolveNavigationDestination(String navigateTo) async {
  final name = navigateTo.trim();
  if (name.isEmpty) return '';

  try {
    final db = FirebaseFirestore.instance;

    final offices = await db
        .collection('offices')
        .where('office_name', isEqualTo: name)
        .limit(1)
        .get();
    if (offices.docs.isNotEmpty) {
      final slot = offices.docs.first.data()['map_slot'];
      if (slot is String && slot.trim().isNotEmpty) return slot.trim();
    }

    final rooms = await db
        .collection('other_room')
        .where('room_name', isEqualTo: name)
        .limit(1)
        .get();
    if (rooms.docs.isNotEmpty) {
      final slot = rooms.docs.first.data()['map_slot'];
      if (slot is String && slot.trim().isNotEmpty) return slot.trim();
    }
  } catch (e) {
    debugPrint('resolveNavigationDestination failed: $e');
  }
  return name;
}

class UnityNavigationScreen extends StatefulWidget {
  /// A map_slot or name. Empty = free access (no destination).
  final String destination;

  const UnityNavigationScreen({super.key, this.destination = ''});

  @override
  State<UnityNavigationScreen> createState() => _UnityNavigationScreenState();
}

class _UnityNavigationScreenState extends State<UnityNavigationScreen> {
  // Unity loads once and then stays in memory, so remember that it has loaded.
  static bool _loadedOnce = false;

  late bool _ready = _loadedOnce;

  @override
  void initState() {
    super.initState();
    // If Unity is already loaded (a later visit), this reaches it right away.
    // On the very first visit it is ignored, and the "ready" message below covers it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _openSession());
  }

  void _openSession() {
    sendToUnity('FlutterBridge', 'OpenSession', widget.destination);
  }

  void _onMessageFromUnity(String message) {
    switch (message) {
      case 'ready':
        _loadedOnce = true;
        if (mounted) setState(() => _ready = true);
        _openSession();
        break;
      case 'exit':
        if (mounted) Navigator.of(context).pop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_ready) {
          // Unity shows its own "Exit Navigation?" modal.
          sendToUnity('FlutterBridge', 'OnBackPressed', '');
        } else {
          Navigator.of(context).pop();   // Unity hasn't loaded yet, so just leave.
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: EmbedUnity(onMessageFromUnity: _onMessageFromUnity),
            ),
            if (!_ready)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
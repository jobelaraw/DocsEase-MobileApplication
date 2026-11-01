import 'dart:async';
import 'package:docsease/app_modals.dart';
import 'package:docsease/authentication.dart';
import 'package:docsease/firebase_services.dart';
import 'package:docsease/main.dart';
import 'package:docsease/settings_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

/// Change this to Duration(seconds: 20) when testing.
const Duration kIdleTimeout = Duration(minutes: 1);
const String kLastActiveKey = 'lastActiveAt';

class IdleTimeoutWrapper extends StatefulWidget {
  final Widget child;
  const IdleTimeoutWrapper({super.key, required this.child});

  @override
  State<IdleTimeoutWrapper> createState() => _IdleTimeoutWrapperState();
}

class _IdleTimeoutWrapperState extends State<IdleTimeoutWrapper>
    with WidgetsBindingObserver {
  Timer? _timer;
  StreamSubscription<User?>? _authSub;
  DateTime _lastActive = DateTime.now();
  DateTime _lastSaved = DateTime.fromMillisecondsSinceEpoch(0);
  bool _loggingOut = false;

  Box get _box => Hive.box('auth_box');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Fires right away with the current user, then on every login/logout.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _timer?.cancel();
        _box.delete(kLastActiveKey);
      } else {
        _markActive(force: true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  // Called on every touch. Restarts the 15-minute countdown.
  void _markActive({bool force = false}) {
    if (_loggingOut || FirebaseAuth.instance.currentUser == null) return;

    final now = DateTime.now();
    // Ignore touches that come less than 1 second apart (saves work while scrolling)
    if (!force && now.difference(_lastActive) < const Duration(seconds: 1)) return;

    _lastActive = now;
    _timer?.cancel();
    _timer = Timer(kIdleTimeout, _logout);

    // Save the time so we can check it again if the app is closed
    if (force || now.difference(_lastSaved) > const Duration(seconds: 10)) {
      _box.put(kLastActiveKey, now.millisecondsSinceEpoch);
      _lastSaved = now;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (FirebaseAuth.instance.currentUser == null) return;

    if (state == AppLifecycleState.paused) {
      // Timers are not reliable in the background, so save the time instead
      _timer?.cancel();
      _box.put(kLastActiveKey, _lastActive.millisecondsSinceEpoch);
    } else if (state == AppLifecycleState.resumed) {
      if (DateTime.now().difference(_lastActive) >= kIdleTimeout) {
        _logout();
      } else {
        _markActive(force: true);
      }
    }
  }

  Future<void> _logout() async {
    if (_loggingOut || FirebaseAuth.instance.currentUser == null) return;
    _loggingOut = true;
    _timer?.cancel();

    final settings = context.read<SettingsProvider>();

    try {
      // Same steps as the Logout button in side_bar.dart
      settings.revertDarkModePreview();
      await FirebaseServices().signOutUser();
      await settings.loadSettings();
      await settings.saveSettings(false, settings.language, 0.5);
      await _box.delete(kLastActiveKey);

      final nav = navigatorKey.currentState;
      if (nav == null) return;

      // This also closes any open dialogs or screens
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
            (route) => false,
      );
      nav.push(MaterialPageRoute(builder: (_) => const Authentication()));

      // Wait for the new screen, then tell the user why they were logged out
      await Future.delayed(const Duration(milliseconds: 400));
      final overlayContext = navigatorKey.currentState?.overlay?.context;
      if (overlayContext != null && overlayContext.mounted) {
        SessionExpiredModal.show(overlayContext);
      }
    } catch (e) {
      debugPrint('Idle logout error: $e');
    } finally {
      _loggingOut = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listener sees every touch without blocking the buttons underneath
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _markActive(),
      onPointerMove: (_) => _markActive(),
      onPointerUp: (_) => _markActive(),
      child: widget.child,
    );
  }
}
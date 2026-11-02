import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkCheck {
  // Several hosts, so one blocked or slow site can't cause a false "offline".
  static const List<String> _hosts = [
    'google.com',
    'cloudflare.com',
    'firebase.google.com',
    'api.emailjs.com',
  ];

  /// true = the phone can reach the internet.
  static Future<bool> hasInternet() async {
    if (kIsWeb) return true;

    // Works with both old (single value) and new (list) connectivity_plus.
    final dynamic raw = await Connectivity().checkConnectivity();
    final List<dynamic> results = raw is List ? raw : [raw];
    debugPrint('NET connectivity: $results');

    // Only say "offline" if the phone itself reports no connection at all.
    if (results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none)) {
      return false;
    }

    // Try all hosts at the same time. One success is enough.
    final completer = Completer<bool>();
    int failed = 0;

    void fail(String host, Object error) {
      debugPrint('NET lookup failed: $host -> $error');
      failed++;
      if (failed == _hosts.length && !completer.isCompleted) {
        completer.complete(false);
      }
    }

    for (final host in _hosts) {
      InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 6))
          .then((addresses) {
        if (addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty) {
          debugPrint('NET lookup ok: $host');
          if (!completer.isCompleted) completer.complete(true);
        } else {
          fail(host, 'empty result');
        }
      }).catchError((Object e) {
        fail(host, e);
      });
    }

    return completer.future;
  }
}
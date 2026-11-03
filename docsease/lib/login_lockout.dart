import 'dart:math';
import 'package:hive/hive.dart';

/// Per-email sign-in lockout.
///
/// After [maxAttempts] wrong passwords in a row, sign-in for that email is
/// blocked for [lockDuration]. When the lock ends, counting starts fresh.
/// Stored in the existing 'auth_box' Hive box, so it survives app restarts.
///
/// NOTE: this is a client-side protection. It protects this app on this device;
/// clearing the app data or reinstalling resets it. Firebase Auth also applies
/// its own throttling on top (it answers "too-many-requests").
class LoginLockout {
  LoginLockout._();

  static const int maxAttempts = 5;
  static const Duration lockDuration = Duration(minutes: 10);
  static const String _storeKey = 'login_attempts';

  static String _norm(String email) => email.trim().toLowerCase();

  // { email: { 'failures': n, 'lockedUntil': millisecondsSinceEpoch or 0 } }
  static Map<String, Map<String, int>> _readAll() {
    final raw = Hive.box('auth_box').get(_storeKey);
    final result = <String, Map<String, int>>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is Map) {
          result[key.toString()] = {
            'failures': (value['failures'] as num?)?.toInt() ?? 0,
            'lockedUntil': (value['lockedUntil'] as num?)?.toInt() ?? 0,
          };
        }
      });
    }
    return result;
  }

  static void _writeAll(Map<String, Map<String, int>> data) {
    final box = Hive.box('auth_box');
    if (data.isEmpty) {
      box.delete(_storeKey);
    } else {
      box.put(_storeKey, data);
    }
  }

  /// Time left on the lock for [email] (Duration.zero if it is not locked).
  static Duration remaining(String email) {
    final key = _norm(email);
    if (key.isEmpty) return Duration.zero;

    final all = _readAll();
    final entry = all[key];
    if (entry == null) return Duration.zero;

    final lockedUntil = entry['lockedUntil'] ?? 0;
    if (lockedUntil == 0) return Duration.zero;

    final left = DateTime.fromMillisecondsSinceEpoch(lockedUntil)
        .difference(DateTime.now());
    if (left > Duration.zero) return left;

    // The lock has finished: forget it so the user gets a fresh set of attempts.
    all.remove(key);
    _writeAll(all);
    return Duration.zero;
  }

  static bool isLocked(String email) => remaining(email) > Duration.zero;

  /// Records one wrong password for [email].
  /// Returns how many attempts are left (0 means sign-in is locked now).
  static int registerFailure(String email) {
    final key = _norm(email);
    if (key.isEmpty) return maxAttempts;

    // Also clears an expired lock, so counting restarts from zero afterwards.
    if (remaining(key) > Duration.zero) return 0;

    final all = _readAll();
    final failures = (all[key]?['failures'] ?? 0) + 1;

    if (failures >= maxAttempts) {
      all[key] = {
        'failures': failures,
        'lockedUntil':
        DateTime.now().add(lockDuration).millisecondsSinceEpoch,
      };
    } else {
      all[key] = {'failures': failures, 'lockedUntil': 0};
    }
    _writeAll(all);

    return max(0, maxAttempts - failures);
  }

  /// Call after a successful sign-in or a completed password reset.
  static void reset(String email) {
    final key = _norm(email);
    if (key.isEmpty) return;

    final all = _readAll();
    if (all.remove(key) != null) _writeAll(all);
  }
}
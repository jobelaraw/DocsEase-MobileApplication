import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:docsease/agreement_modal.dart';
import 'package:docsease/legal_content.dart';

/// Device-level consent for guests. Guests have no account, so the accepted
/// version is stored locally in the existing 'auth_box' Hive box.
class GuestAgreement {
  GuestAgreement._();

  static const String _key = 'guestAgreedVersion';

  /// True if this device already accepted the current legal version.
  static bool get hasAccepted =>
      Hive.box('auth_box').get(_key) == LegalContent.version;

  /// Always opens the modal (e.g. when the user taps a Terms/Privacy link) and
  /// records acceptance on this device if the user taps "I Agree".
  static Future<bool> show(
      BuildContext context, {
        AgreementTab tab = AgreementTab.terms,
      }) async {
    final accepted = await AgreementModal.show(context, initialTab: tab);
    if (accepted) {
      await Hive.box('auth_box').put(_key, LegalContent.version);
    }
    return accepted;
  }

  /// Skips the modal if the current version was already accepted on this
  /// device. Returns true when the guest may continue.
  static Future<bool> ensureAccepted(
      BuildContext context, {
        AgreementTab tab = AgreementTab.terms,
      }) async {
    if (hasAccepted) return true;
    return show(context, tab: tab);
  }
}
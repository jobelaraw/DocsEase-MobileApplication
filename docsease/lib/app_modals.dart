import 'package:flutter/material.dart';
import 'package:docsease/app_localizations.dart';
import 'package:docsease/settings_provider.dart';
import 'package:provider/provider.dart';

Future<T?> _showAppModal<T>({required BuildContext context, required Widget child}) {
  return showDialog<T>(context: context, barrierColor: Colors.black54, builder: (_) => child);
}

const _kBlue = Color(0xFF2563EB);
const _kRed = Color(0xFFEF4444);
const _kGreen = Color(0xFF22C55E);
const _kIconBgRed = Color(0xFFFFE4E6);
const _kIconBgGreen = Color(0xFFDCFCE7);
const _kIconBgBlue = Color(0xFFDBEAFE);

class _AppModalBase extends StatefulWidget {
  const _AppModalBase({
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.primaryLabel = 'Yes',
    this.primaryColor = _kBlue,
    this.secondaryLabel,
    required this.onPrimary,
    this.onSecondary,
    this.singleAction = false,
    this.extraContent,
  });

  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final String primaryLabel;
  final Color primaryColor;
  final String? secondaryLabel;
  final Function onPrimary; // Changed to dynamic Function to accept async callbacks
  final VoidCallback? onSecondary;
  final bool singleAction;
  final Widget? extraContent;

  @override
  State<_AppModalBase> createState() => _AppModalBaseState();
}

class _AppModalBaseState extends State<_AppModalBase> {
  bool _isLoading = false;

  Future<void> _handlePrimary() async {
    setState(() {
      _isLoading = true;
    });

    // Execute the callback. If it is asynchronous, await it!
    var result = widget.onPrimary();
    if (result is Future) {
      await result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.primary
          : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: IntrinsicHeight(
          child: Stack(
            children: [
              // contents
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // icons
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.iconData, color: widget.iconColor, size: 24),
                    ),
                    const SizedBox(height: 15),

                    // Title
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),

                    //subtitle
                    if (widget.subtitle != null) ...[
                      Text(
                        widget.subtitle!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.onPrimary
                              : const Color(0xFF4B5563),
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    if (widget.extraContent != null) ...[
                      const SizedBox(height: 12),
                      widget.extraContent!,
                    ],

                    // Buttons
                    if (widget.singleAction)
                      _buildSecondaryButton(context, widget.primaryLabel, _handlePrimary)
                    else ...[
                      _buildPrimaryButton(context, widget.primaryLabel, _handlePrimary),
                      const SizedBox(height: 12),
                      _buildSecondaryButton(
                        context,
                        widget.secondaryLabel ?? 'Cancel',
                        widget.onSecondary ?? () => Navigator.of(context).pop(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //first button
  Widget _buildPrimaryButton(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 35,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: widget.primaryColor,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  //second button
  Widget _buildSecondaryButton(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 35,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF374151),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading && widget.singleAction
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(color: Color(0xFF374151), strokeWidth: 2.5),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onPrimary
                      : const Color(0xFF374151),
                ),
              ),
      ),
    );
  }
}

//Exit confirmation modal
class ExitConfirmationModal {
  static Future<void> show(BuildContext context, {Function? onPrimary, VoidCallback? onSecondary}) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    String tr(String key) => AppLocalizations.translate(key, lang);

    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.warning_amber_rounded,
        iconColor: _kRed,
        iconBgColor: _kIconBgRed,
        title: tr('Are you sure you want to exit?'),
        subtitle: tr('Changes will not be saved if you leave this page.'),
        primaryLabel: tr('Yes'),
        primaryColor: _kRed,
        onPrimary: onPrimary ?? () => Navigator.of(context).pop(),
        secondaryLabel: tr('Cancel'),
        onSecondary: onSecondary ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}

//Changes saved modal
class ChangesSavedModal {
  static Future<void> show(BuildContext context, {required Function onPrimary, String? subtitle}) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    String tr(String key) => AppLocalizations.translate(key, lang);

    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.check_circle_outline_rounded,
        iconColor: _kGreen,
        iconBgColor: _kIconBgGreen,
        title: tr('Changes Saved!'),
        subtitle: tr('Updated successfully. Please click to continue.'),
        primaryLabel: tr('Got it'),
        singleAction: true,
        onPrimary: onPrimary,
      ),
    );
  }
}

//Confirm changes modal
class ConfirmChangesModal {
  static Future<void> show(
    BuildContext context, {
    required Function onPrimary,
    VoidCallback? onSecondary,
  }) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    String tr(String key) => AppLocalizations.translate(key, lang);

    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.info_outline_rounded,
        iconColor: const Color(0xFF3B82F6),
        iconBgColor: _kIconBgBlue,
        title: tr('Confirm Changes'),
        subtitle: tr('Are you sure you want to save changes?'),
        primaryLabel: tr('Yes'),
        primaryColor: const Color(0xFF3B82F6),
        onPrimary: onPrimary,
        secondaryLabel: tr('Cancel'),
        onSecondary: onSecondary ?? () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }
}

//Check email modal
class CheckEmailModal {
  static Future<void> show(BuildContext context, {required Function onPrimary}) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    String tr(String key) => AppLocalizations.translate(key, lang);

    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.check_circle_outline_rounded,
        iconColor: _kGreen,
        iconBgColor: _kIconBgGreen,
        title: tr('Check your Email'),
        subtitle: tr('A recovery code has been sent to your email. Please check your inbox.'),
        primaryLabel: tr('Got it'),
        singleAction: true,
        onPrimary: onPrimary,
      ),
    );
  }
}

//Require sign in modal
class RequireSignInModal {
  static Future<void> show(BuildContext context, {Function? onPrimary, required String title}) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    String tr(String key) => AppLocalizations.translate(key, lang);

    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.person_rounded,
        iconColor: const Color(0xFF3B82F6),
        iconBgColor: _kIconBgBlue,
        title: title == "Profile"
            ? tr('Profile Requires Authentication')
            : title == 'Chatbot'
            ? tr('DocsEase Bot Requires Authentication')
            : tr('Service History Requires Authentication'),
        subtitle: tr("You'll be directed to sign in screen. Are you sure you want to continue?"),
        primaryLabel: tr('Yes'),
        primaryColor: const Color(0xFF3B82F6),
        secondaryLabel: tr('Cancel'),
        onPrimary: () async {
          // Instantly displays the loading spinner for 800ms
          await Future.delayed(const Duration(milliseconds: 800));
          if (onPrimary != null) {
            var res = onPrimary();
            if (res is Future) await res;
          } else {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
        onSecondary: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }
}

//Verified modal
class VerifiedModal {
  static Future<void> show(BuildContext context, {required Function onPrimary}) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    String tr(String key) => AppLocalizations.translate(key, lang);

    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.check_circle_outline_rounded,
        iconColor: _kGreen,
        iconBgColor: _kIconBgGreen,
        title: tr('Verified'),
        subtitle: tr('Code verified successfully. You may now change your password.'),
        primaryLabel: tr('Got it'),
        singleAction: true,
        onPrimary: onPrimary,
      ),
    );
  }
}

//Resend Recovery Code Modal
class ResendCodeModal {
  static Future<void> show(BuildContext context, {required Function onPrimary}) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    String tr(String key) => AppLocalizations.translate(key, lang);

    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.check_circle_outline_rounded,
        iconColor: _kGreen,
        iconBgColor: _kIconBgGreen,
        title: tr('New Code Sent'),
        subtitle: tr(
          "We've sent a new recovery code. Please check your inbox for the updated 6-digit recovery code.",
        ),
        primaryLabel: tr('Got it'),
        singleAction: true,
        onPrimary: onPrimary,
      ),
    );
  }
}

//Logout modal
class LogoutModal {
  static Future<void> show(
    BuildContext context, {
    Function? onPrimary,
    bool hasUnsavedChanges = false,
    bool isGuest = false,
  }) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    String tr(String key) => AppLocalizations.translate(key, lang);

    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.logout_rounded,
        iconColor: _kRed,
        iconBgColor: _kIconBgRed,
        title: !isGuest
            ? tr('Are you sure you want to logout?')
            : tr('Are you sure you want to exit?'),
        subtitle: hasUnsavedChanges
            ? tr('You have unsaved Settings changes that will be lost.')
            : null,
        primaryLabel: tr('Yes'),
        primaryColor: _kRed,
        secondaryLabel: tr('Cancel'),
        onPrimary: () async {
          // Instantly displays the loading spinner for 800ms
          await Future.delayed(const Duration(milliseconds: 800));
          if (onPrimary != null) {
            var res = onPrimary();
            if (res is Future) await res;
          } else {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
        onSecondary: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }
}

//ProfileChanges modal
class ProfileChangesModal {
  static Future<void> show(BuildContext context, {VoidCallback? onPrimary}) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    String tr(String key) => AppLocalizations.translate(key, lang);

    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.logout_rounded,
        iconColor: _kRed,
        iconBgColor: _kIconBgRed,
        title: tr('Are you sure you want to back?'),
        subtitle: tr('Changes will not be saved if you leave this page.'),
        primaryLabel: tr('Yes'),
        primaryColor: _kRed,
        secondaryLabel: tr('Cancel'),
        onPrimary: onPrimary ?? () => Navigator.of(context, rootNavigator: true).pop(),
        onSecondary: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }
}

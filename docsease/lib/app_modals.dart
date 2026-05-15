import 'package:flutter/material.dart';

Future<T?> _showAppModal<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => child,
  );
}

const _kBlue = Color(0xFF2563EB);
const _kRed = Color(0xFFEF4444);
const _kGreen = Color(0xFF22C55E);
const _kIconBgRed = Color(0xFFFFE4E6);
const _kIconBgGreen = Color(0xFFDCFCE7);
const _kIconBgBlue = Color(0xFFDBEAFE);

class _AppModalBase extends StatelessWidget {
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
  });

  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final String primaryLabel;
  final Color primaryColor;
  final String? secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final bool singleAction;

  @override
Widget build(BuildContext context) {
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    backgroundColor: Colors.white,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(20), 
      child: IntrinsicHeight(
        child: Stack(
          children: [
            
            // contents
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  
                  // icons
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: iconColor, size: 24),
                  ), 
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  
                  //subtitle
                  if (subtitle != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Buttons
                  if (singleAction)
                    _buildSecondaryButton(context, primaryLabel, onPrimary)
                  else ...[
                    _buildPrimaryButton(primaryLabel, onPrimary),
                    const SizedBox(height: 12),
                    _buildSecondaryButton(
                      context,
                      secondaryLabel ?? 'Cancel',
                      onSecondary ?? () => Navigator.of(context).pop(),
                    ),
                  ],
                ],
              ),
            ),

            // close button "X"
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  //first button
  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 35,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
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
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

//Exit confirmation modal
class ExitConfirmationModal {
  static Future<void> show(BuildContext context, {VoidCallback? onPrimary, VoidCallback? onSecondary}) {
    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.warning_amber_rounded,
        iconColor: _kRed,
        iconBgColor: _kIconBgRed,
        title: 'Are you sure you want to exit?',
        subtitle: 'Changes will not be saved if you leave this page.',
        primaryLabel: 'Yes',
        primaryColor: _kRed,
        onPrimary: onPrimary ?? () => Navigator.of(context).pop(),
        onSecondary: onSecondary ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}

//Changes saved modal
class ChangesSavedModal {
  static Future<void> show(BuildContext context, {required VoidCallback onPrimary, String? subtitle}) {
    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.check_circle_outline_rounded,
        iconColor: _kGreen,
        iconBgColor: _kIconBgGreen,
        title: 'Changes Saved!',
        subtitle: 'Password updated successfully. Redirecting you to sign in screen.',
        primaryLabel: 'Got it',
        singleAction: true,
        onPrimary: onPrimary,
      ),
    );
  }
}

//Confirm changes modal
class ConfirmChangesModal {
  static Future<void> show(BuildContext context, {required VoidCallback onPrimary, VoidCallback? onSecondary}) {
    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.info_outline_rounded,
        iconColor: const Color(0xFF3B82F6),
        iconBgColor: _kIconBgBlue,
        title: 'Confirm Changes',
        subtitle: 'Are you sure you want to save changes?',
        primaryLabel: 'Yes',
        primaryColor: const Color(0xFF3B82F6),
        onPrimary: onPrimary,
        secondaryLabel: 'Cancel',
        onSecondary: onSecondary ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}

//Check email modal
class CheckEmailModal {
  static Future<void> show(BuildContext context, {required VoidCallback onPrimary}) {
    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.check_circle_outline_rounded,
        iconColor: _kGreen,
        iconBgColor: _kIconBgGreen,
        title: 'Check your Email',
        subtitle: 'A recovery code has been sent to your email. Please check your inbox.',
        primaryLabel: 'Got it',
  
        singleAction: true,
        onPrimary: onPrimary,
      ),
    );
  }
}

//Profile sign in modal
class ProfileSignInModal {
  static Future<void> show(BuildContext context) {
    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.person_rounded,
        iconColor: const Color(0xFF3B82F6),
        iconBgColor: _kIconBgBlue,
        title: 'Profile Requires Sign in',
        subtitle: "You'll be directed to sign in screen. Are you sure you want to continue?",
        primaryLabel: 'Yes',
        primaryColor: const Color(0xFF3B82F6),
        onPrimary: () => Navigator.of(context).pop(),
      ),
    );
  }
}

//Verified modal
class VerifiedModal {
  static Future<void> show(BuildContext context, {required VoidCallback onPrimary}) {
    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.check_circle_outline_rounded,
        iconColor: _kGreen,
        iconBgColor: _kIconBgGreen,
        title: 'Verified',
        subtitle: 'Code verified successfully. You may now change your password.',
        primaryLabel: 'Got it',
  
        singleAction: true,
        onPrimary: onPrimary,
      ),
    );
  }
}

//Resend Recovery Code Modal
class ResendCodeModal {
  static Future<void> show(BuildContext context, {required VoidCallback onPrimary}) {
    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.check_circle_outline_rounded,
        iconColor: _kGreen,
        iconBgColor: _kIconBgGreen,
        title: 'New Code Sent',
        subtitle: 'We’ve sent a new recovery code. Please check your inbox for the updated 6-digit recovery code.',
        primaryLabel: 'Got it',

        singleAction: true,
        onPrimary: onPrimary,
      ),
    );
  }
}

//Logout modal
class LogoutModal {
  static Future<void> show(BuildContext context, {VoidCallback? onPrimary}) {
    return _showAppModal<void>(
      context: context,
      child: _AppModalBase(
        iconData: Icons.logout_rounded,
        iconColor: _kRed,
        iconBgColor: _kIconBgRed,
        title: 'Are you sure you want to logout?',
        primaryLabel: 'Yes',
        primaryColor: _kRed,
        secondaryLabel: 'Cancel',
        onPrimary: onPrimary ?? () => Navigator.of(context).pop(),
        onSecondary: () => Navigator.of(context).pop(),
      ),
    );
  }
}
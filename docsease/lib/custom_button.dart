import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class CustomButton extends StatefulWidget {
  final String buttonText;
  final bool isGoogle;
  final bool isLoading;
  final bool isButtonEnabled;
  final double btnElevation;
  final double btnRadius;
  final VoidCallback onTapAction;

  const CustomButton({
    super.key,
    required this.buttonText,
    this.isGoogle = false,
    this.isLoading = false,
    this.isButtonEnabled = true,
    this.btnElevation = 10,
    this.btnRadius = 25,
    required this.onTapAction,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDark
        ? Theme.of(context).colorScheme.tertiary
        : const Color.fromRGBO(59, 115, 224, 1.0);

    // "Looks disabled" only when the button is NOT enabled. While loading, the
    // button is also non-tappable but must stay blue so the spinner is visible.
    final bool looksDisabled = !widget.isButtonEnabled;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: widget.isGoogle
          ? OutlinedButton(
        onPressed: widget.isLoading ? null : widget.onTapAction,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.black.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.btnRadius),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
          height: 40,
          child: Transform.scale(
            scale: 1.5,
            child: Transform.translate(
              offset: const Offset(0, -7),
              child: Lottie.asset('assets/Loading.json'),
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/google_icon.png', height: 35, width: 35),
            const SizedBox(width: 8),
            Text(
              widget.buttonText,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      )
          : ElevatedButton(
        onPressed: widget.isButtonEnabled
            ? widget.isLoading
            ? null
            : widget.onTapAction
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: activeColor,
          foregroundColor: Colors.white,
          // Gray, flat, no glow when the button is not enabled.
          disabledBackgroundColor: looksDisabled
              ? (isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFD5DAE3))
              : activeColor,
          disabledForegroundColor: looksDisabled
              ? (isDark ? Colors.white38 : const Color(0xFF8B94A5))
              : Colors.white,
          elevation: looksDisabled ? 0 : widget.btnElevation,
          shadowColor: looksDisabled ? Colors.transparent : activeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.btnRadius),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
          height: 40,
          child: Transform.scale(
            scale: 1.5,
            child: Transform.translate(
              offset: const Offset(0, -7),
              child: Lottie.asset('assets/Loading.json'),
            ),
          ),
        )
            : Text(
          widget.buttonText,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
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
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: widget.isGoogle
          ? OutlinedButton.icon(
              onPressed: widget.isLoading ? null : widget.onTapAction,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.black.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.btnRadius),
                ),
              ),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/google_icon.png', height: 35, width: 35),
                  Text(
                    widget.buttonText,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (widget.isLoading) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30, //28
                      height: 30,
                      child: Lottie.asset('assets/Loading.json', fit: BoxFit.contain),
                    ),
                  ],
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
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.tertiary
                  : const Color.fromRGBO(59, 115, 224, 1.0),
                foregroundColor: Colors.white,
                elevation: widget.btnElevation,
                shadowColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.tertiary
                  : const Color.fromRGBO(59, 115, 224, 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.btnRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.buttonText,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (widget.isLoading) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30, //28
                      height: 30,
                      child: Lottie.asset('assets/Loading.json', fit: BoxFit.contain),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

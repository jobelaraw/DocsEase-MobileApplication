import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgotpass_email.dart';
import 'navigator_transition.dart';


class CustomTextField extends StatefulWidget {
  final String inputLabel;
  final String inputHint;
  final TextInputType inputType;
  final bool isPassword;
  final bool isLoginPass;
  final TextEditingController controller;
  final String? Function(String)? validator;
  final void Function(String)? onChanged;
  final bool forceValidate;
  final bool showSuccessState;
  final String receivedPassword;
  final bool liveSuccessValidation;

  const CustomTextField({
    super.key,
    required this.inputLabel,
    required this.inputHint,
    required this.inputType,
    required this.controller,
    this.isPassword = false,
    this.isLoginPass = false,
    this.validator,
    this.onChanged,
    this.forceValidate = false,
    this.showSuccessState = true,
    this.receivedPassword = '',
    this.liveSuccessValidation = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool hidePassword = true;
  bool isHovered = false;

  late FocusNode focusNode;
  String? errorText;
  bool isSuccess = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus && widget.validator != null) {
        setState(() {
          errorText = widget.validator!(widget.controller.text);
          isSuccess = errorText == null && widget.controller.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forceValidate != oldWidget.forceValidate) {
      if (widget.validator != null) {
        setState(() {
          errorText = widget.validator!(widget.controller.text);
          isSuccess = errorText == null && widget.controller.text.isNotEmpty;
        });
      }
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasError = errorText != null;
    bool displaySuccess = isSuccess && widget.showSuccessState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.isLoginPass
            ? Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.inputLabel,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onHover: (hovering) {
                        setState(() {
                          isHovered = hovering;
                        });
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          SlideRoute(page: const ForgotPasswordEmailScreen()),
                        );
                      }, // Change later on
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isHovered
                              ? Color.fromRGBO(24, 74, 182, 1)
                              : Color.fromRGBO(59, 115, 224, 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 5),
                  child: Text(
                    widget.inputLabel,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
        // SizedBox(height: 5),
        SizedBox(
          height: 50,
          child: TextField(
            controller: widget.controller,
            focusNode: focusNode,
            obscureText: widget.isPassword ? hidePassword : false,
            keyboardType: widget.inputType,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.normal),
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }

              setState(() {
                if (widget.liveSuccessValidation && widget.validator != null) {
                  String? tempError = widget.validator!(value);
                  isSuccess = tempError == null && value.isNotEmpty;
                  if (hasError) {
                    errorText = tempError;
                  }
                } else {
                  isSuccess = false;
                  if (hasError && widget.validator != null) {
                    errorText = widget.validator!(value);
                  }
                }
              });
            },
            decoration: InputDecoration(
              hintText: widget.inputHint,
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              filled: true,
              fillColor: hasError
                  ? Colors.red.withOpacity(0.03)
                  : displaySuccess
                  ? Colors.green.withOpacity(0.03)
                  : (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.0),
                borderSide: BorderSide(
                  color: hasError
                      ? Colors.red
                      : displaySuccess
                      ? Colors.green
                      : (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.black.withOpacity(0.3)),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.0),
                borderSide: BorderSide(
                  color: hasError
                      ? Colors.red
                      : displaySuccess
                      ? Colors.green
                      : Color.fromRGBO(59, 115, 224, 1.0),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasError)
                    Padding(
                      padding: widget.isPassword
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(right: 10),
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  if (displaySuccess && !hasError)
                    Padding(
                      padding: widget.isPassword
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(right: 12),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (widget.isPassword)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      color: hasError
                          ? Colors.red.withOpacity(0.5)
                          : displaySuccess
                          ? Colors.green.withOpacity(0.5)
                          : (Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.black.withOpacity(0.3)),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutBack, // Gives it that satisfying bounce!
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0, // Anchors the animation to the bottom of the text field
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
            );
          },
          child: hasError
              ? Padding(
                  // Change errorText to static value 'error' if we want to remove the exit bounce from text to another
                  key: ValueKey(errorText),
                  padding: const EdgeInsets.only(top: 5, left: 10),
                  child: Text(
                    errorText!,
                    style: GoogleFonts.inter(
                      color: const Color.fromRGBO(255, 100, 100, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty_indicator')),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutBack, // Gives it that satisfying bounce!
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0, // Anchors the animation to the bottom of the text field
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
            );
          },
          child: widget.receivedPassword.isNotEmpty
              ? Container(
                  key: const ValueKey('password_indicator'),
                  child: buildPasswordStrengthIndicator(),
                )
              : const SizedBox.shrink(key: ValueKey('empty_indicator')),
        ),
      ],
    );
  }

  Widget buildPasswordStrengthIndicator() {
    bool hasLength = widget.receivedPassword.length >= 8;
    bool hasSymbol = RegExp(r'[^a-zA-Z0-9\s]').hasMatch(widget.receivedPassword);
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(widget.receivedPassword);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(widget.receivedPassword);

    int score =
        (hasLength ? 1 : 0) + (hasSymbol ? 1 : 0) + (hasUppercase ? 1 : 0) + (hasNumber ? 1 : 0);

    String strengthText = 'Weak';
    Color strengthColor = const Color.fromRGBO(255, 100, 100, 1);
    if (score == 4) {
      strengthText = 'Good';
      strengthColor = Colors.green;
    } else if (score == 3) {
      strengthText = 'Fair';
      strengthColor = Colors.orangeAccent;
    }

    Widget buildCriteria(String text, bool isMet) {
      return Row(
        children: [
          Icon(
            isMet ? Icons.check : Icons.close,
            color: isMet ? Colors.green : const Color.fromRGBO(255, 100, 100, 1),
            size: 14,
            fontWeight: FontWeight.w800,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isMet ? Colors.green : const Color.fromRGBO(255, 100, 100, 1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCriteria("Use at least 8 characters", hasLength),
              const SizedBox(height: 3),
              buildCriteria("Add a symbol (like ! or #)", hasSymbol),
              const SizedBox(height: 3),
              buildCriteria("Include a capital letter", hasUppercase),
              const SizedBox(height: 3),
              buildCriteria("Include a number", hasNumber),
            ],
          ),
          Text(
            strengthText,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: strengthColor,
            ),
          ),
        ],
      ),
    );
  }
}

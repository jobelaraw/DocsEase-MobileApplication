import 'package:docsease/side_bar.dart';
import 'package:docsease/users_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(32, 87, 206, 1.0),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromRGBO(10, 49, 104, 1),
                            width: 1.0,
                          ),
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/docsease_logo.png",
                            height: 50,
                            width: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'DocsEase',
                        style: GoogleFonts.inter(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Smart Assistant for\ngovernment procedures.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(251, 243, 243, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                        child: TabBar(
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          labelColor: const Color.fromRGBO(59, 115, 224, 1.0),
                          unselectedLabelColor: Colors.grey,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: const UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(32, 87, 206, 1.0),
                              width: 1.5,
                            ),
                          ),
                          tabs: const [
                            Tab(text: 'Sign In'),
                            Tab(text: 'Sign Up'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                              child: const SignIn(),
                            ),
                            SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                              child: const SignUp(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        CustomTextField(
          inputLabel: 'EMAIL ADDRESS',
          inputHint: 'Enter your email',
          inputType: TextInputType.emailAddress,
          isPassword: false,
          isLoginPass: false,
          controller: emailController,
        ),
        const SizedBox(height: 30),
        CustomTextField(
          inputLabel: 'PASSWORD',
          inputHint: 'Enter your password',
          inputType: TextInputType.visiblePassword,
          isPassword: true,
          isLoginPass: true,
          controller: passwordController,
        ),
        const SizedBox(height: 30),
        CustomButton(
          buttonText: 'Sign In',
          isGoogle: false,
          isLoading: _isLoading,
          onTapAction: () async {
            try {
              setState(() => _isLoading = true);
              final authService = AuthService();
              await authService.signIn(
                emailController.text.trim(),
                passwordController.text,
              );
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SideBar()),
                  (Route<dynamic> route) => false,
                );
              }
            } catch (e) {
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Login Failed: ${e.toString()}")),
                );
              }
            }
          },
        ),
        const SizedBox(height: 20),
        const CustomDivider(),
        const SizedBox(height: 20),
        CustomButton(
          buttonText: 'Continue with Google',
          isGoogle: true,
          onTapAction: () {},
        ),
        const SizedBox(height: 30),
        Text(
          'Don\'t want to create an account?',
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 10),
        const CustomTextButton(inkwellText: 'Continue as Guest', continueGuest: true),
      ],
    );
  }
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          inputLabel: 'USERNAME',
          inputHint: 'Enter your username',
          inputType: TextInputType.text,
          isPassword: false,
          isLoginPass: false,
          controller: usernameController,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          inputLabel: 'EMAIL ADDRESS',
          inputHint: 'Enter your email',
          inputType: TextInputType.emailAddress,
          isPassword: false,
          isLoginPass: false,
          controller: emailController,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          inputLabel: 'PASSWORD',
          inputHint: 'Enter your password',
          inputType: TextInputType.visiblePassword,
          isPassword: true,
          isLoginPass: false,
          controller: passwordController,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          inputLabel: 'CONFIRM PASSWORD',
          inputHint: 'Confirm your password',
          inputType: TextInputType.visiblePassword,
          isPassword: true,
          isLoginPass: false,
          controller: confirmController,
        ),
        const SizedBox(height: 30),
        CustomButton(
          buttonText: 'Sign Up',
          isGoogle: false,
          onTapAction: () async {
            if (passwordController.text == confirmController.text) {
              await _authService.signUp(
                emailController.text.trim(),
                passwordController.text.trim(),
                usernameController.text.trim(),
              );
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SideBar()),
                      (Route<dynamic> route) => false,
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Passwords do not match!")),
              );
            }
          },
        ),
        const SizedBox(height: 20),
        const CustomDivider(),
        const SizedBox(height: 20),
        CustomButton(
          buttonText: 'Continue with Google',
          isGoogle: true,
          onTapAction: () {},
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(width: 5),
            const CustomTextButton(inkwellText: 'Sign In', continueGuest: false),
          ],
        ),
      ],
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String inputLabel;
  final String inputHint;
  final TextInputType inputType;
  final bool isPassword;
  final bool isLoginPass;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.inputLabel,
    required this.inputHint,
    required this.inputType,
    required this.isPassword,
    required this.isLoginPass,
    required this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool hidePassword = true;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.isLoginPass
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.inputLabel,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onHover: (hovering) {
                setState(() {
                  isHovered = hovering;
                });
              },
              onTap: () {},
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isHovered
                      ? const Color.fromRGBO(24, 74, 182, 1)
                      : const Color.fromRGBO(59, 115, 224, 1.0),
                ),
              ),
            ),
          ],
        )
            : Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.inputLabel,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 40,
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? hidePassword : false,
            keyboardType: widget.inputType,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            decoration: InputDecoration(
              hintText: widget.inputHint,
              hintStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(59, 115, 224, 1.0),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              suffixIcon: widget.isPassword
                  ? Padding(
                padding: const EdgeInsets.all(5),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  color: Colors.black.withOpacity(0.3),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                ),
              )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String buttonText;
  final bool isGoogle;
  final bool isLoading;
  final VoidCallback onTapAction;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.isGoogle,
    required this.onTapAction,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 43,
      child: isGoogle
          ? OutlinedButton.icon(
        onPressed: onTapAction,
        label: Text(
          buttonText,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        icon: Image.asset(
          'assets/google_icon.png',
          height: 35,
          width: 35,
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.black.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      )
          : ElevatedButton(
        onPressed: isLoading ? null : onTapAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(59, 115, 224, 1.0),
          foregroundColor: Colors.white,
          elevation: 10,
          shadowColor: const Color.fromRGBO(59, 115, 224, 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isLoading) ...[
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

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.black.withOpacity(0.2), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'OR',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.black.withOpacity(0.2), thickness: 1),
        ),
      ],
    );
  }
}

class CustomTextButton extends StatefulWidget {
  final String inkwellText;
  final bool continueGuest;

  const CustomTextButton({
    super.key,
    required this.inkwellText,
    required this.continueGuest,
  });

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (hovering) {
        setState(() {
          isHovered = hovering;
        });
      },
      onTap: widget.continueGuest
          ? () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SideBar()),
              (Route<dynamic> route) => false,
        );
      }
          : () {
        DefaultTabController.of(context).animateTo(0);
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 0.5),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isHovered
                  ? const Color.fromRGBO(24, 74, 182, 1)
                  : const Color.fromRGBO(59, 115, 224, 1.0),
              width: 1,
            ),
          ),
        ),
        child: Text(
          widget.inkwellText,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isHovered
                ? const Color.fromRGBO(24, 74, 182, 1)
                : const Color.fromRGBO(59, 115, 224, 1.0),
          ),
        ),
      ),
    );
  }
}
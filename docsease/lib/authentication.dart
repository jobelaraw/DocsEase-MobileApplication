import 'package:docsease/custom_button.dart';
import 'package:docsease/firebase_services.dart';
import 'package:docsease/custom_textfield.dart';
import 'package:docsease/app_modals.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:docsease/settings_provider.dart';

import 'package:hive/hive.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication>
    with SingleTickerProviderStateMixin {
  final TextEditingController _signInEmailController = TextEditingController();
  final TextEditingController _signInPasswordController =
      TextEditingController();
  final TextEditingController _signUpUsernameController =
      TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController =
      TextEditingController();
  final TextEditingController _signUpConfirmController =
      TextEditingController();

  late TabController _tabController;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index != _previousIndex) {
        FocusManager.instance.primaryFocus?.unfocus();

        _signInEmailController.clear();
        _signInPasswordController.clear();
        _signUpUsernameController.clear();
        _signUpEmailController.clear();
        _signUpPasswordController.clear();
        _signUpConfirmController.clear();

        _previousIndex = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 243, 243, 1),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(color: const Color.fromRGBO(32, 87, 206, 1.0)),
          ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(10, 49, 104, 1),
                                  width: 1.0,
                                ),
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  "assets/docsease_logo.png",
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'DocsEase',
                              style: GoogleFonts.inter(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Smart Assistant for\ngovernment procedures.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(251, 243, 243, 1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 20,
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  labelStyle: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overlayColor: MaterialStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  labelColor: Color.fromRGBO(59, 115, 224, 1.0),
                                  unselectedLabelColor: Colors.grey,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: UnderlineTabIndicator(
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
                                  controller: _tabController,
                                  children: [
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        10,
                                        20,
                                        20,
                                      ),
                                      child: SignIn(
                                        emailController: _signInEmailController,
                                        passwordController:
                                            _signInPasswordController,
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        10,
                                        20,
                                        20,
                                      ),
                                      child: SignUp(
                                        usernameController:
                                            _signUpUsernameController,
                                        emailController: _signUpEmailController,
                                        passwordController:
                                            _signUpPasswordController,
                                        confirmController:
                                            _signUpConfirmController,
                                        onTapAction: () {
                                          _tabController.animateTo(0);
                                        },
                                      ),
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
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SignIn extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const SignIn({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        CustomTextField(
          inputLabel: 'EMAIL ADDRESS',
          inputHint: 'Enter your email',
          inputType: TextInputType.emailAddress,
          controller: widget.emailController,
          validator: (value) {
            if (errorMessage != null) {
              return errorMessage;
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              errorMessage = null;
            });
          },
          forceValidate: errorMessage != null,
          showSuccessState: false,
        ),
        const SizedBox(height: 30),
        CustomTextField(
          inputLabel: 'PASSWORD',
          inputHint: 'Enter your password',
          inputType: TextInputType.visiblePassword,
          isPassword: true,
          isLoginPass: true,
          controller: widget.passwordController,
          validator: (value) {
            if (errorMessage != null) {
              return errorMessage;
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              errorMessage = null;
            });
          },
          forceValidate: errorMessage != null,
          showSuccessState: false,
        ),
        SizedBox(height: 40),

        CustomButton(
          buttonText: 'Sign In',
          isLoading: _isEmailLoading,
          isButtonEnabled:
              widget.emailController.text.isNotEmpty &&
              widget.passwordController.text.isNotEmpty,
          onTapAction: () async {
            bool isEmailValid = widget.emailController.text.isNotEmpty;
            bool isPasswordValid = widget.passwordController.text.isNotEmpty;

            if (!isEmailValid || !isPasswordValid) {
              setState(() {
                errorMessage = 'Email or password is required.';
              });
              return;
            }

            final settings = Provider.of<SettingsProvider>(
              context,
              listen: false,
            );

            try {
              settings.setPauseUpdates(true);
              setState(() => _isEmailLoading = true);

              final authService = FirebaseServices();
              String inputEmail = widget.emailController.text
                  .trim()
                  .toLowerCase();
              String inputPassword = widget.passwordController.text;

              await authService.signIn(inputEmail, inputPassword);

              User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                DocumentSnapshot adminDoc = await FirebaseFirestore.instance
                    .collection('admin')
                    .doc(currentUser.uid)
                    .get();

                if (adminDoc.exists) {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    settings.setPauseUpdates(false);
                    setState(() {
                      _isEmailLoading = false;
                      errorMessage = 'Email or password is invalid.';
                    });
                  }
                  return;
                }
              }

              if (mounted) {
                setState(() => _isEmailLoading = false);
                AuthSuccessModal.show(
                  context,
                  title: 'Signed In!',
                  subtitle: 'Welcome back to DocsEase.',
                  onPrimary: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    settings.setPauseUpdates(false);
                  },
                );
              }
            } catch (e) {
              if (mounted) {
                settings.setPauseUpdates(false);
                setState(() {
                  _isEmailLoading = false;
                  errorMessage = 'Email or password is invalid.';
                });
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
          isLoading: _isGoogleLoading,
          onTapAction: () async {
            final settings = Provider.of<SettingsProvider>(
              context,
              listen: false,
            );
            try {
              setState(() => _isGoogleLoading = true);

              final GoogleSignIn googleSignIn = GoogleSignIn();
              await googleSignIn.signOut();
              final googleUser = await googleSignIn.signIn();

              if (googleUser == null) {
                if (mounted) setState(() => _isGoogleLoading = false);
                return;
              }

              settings.setPauseUpdates(true);

              final authService = FirebaseServices();
              final result = await authService.signInWithGoogleStrict(
                googleUser: googleUser,
              );

              if (mounted) {
                setState(() => _isGoogleLoading = false);

                if (result != null) {
                  AuthSuccessModal.show(
                    context,
                    title: 'Signed In!',
                    subtitle: 'Welcome back to DocsEase.',
                    onPrimary: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      settings.setPauseUpdates(false);
                    },
                  );
                } else {
                  settings.setPauseUpdates(false);
                }
              }
            } catch (e) {
              settings.setPauseUpdates(false);
              if (mounted) {
                setState(() => _isGoogleLoading = false);

                if (e is GoogleAccountIsAdminException ||
                    e is GoogleAccountNotRegisteredException) {
                  AuthErrorModal.show(
                    context,
                    title: 'Invalid Google Account',
                    subtitle:
                        'This Google account is not registered as a citizen account.',
                  );
                } else {
                  AuthErrorModal.show(
                    context,
                    title: 'Sign In Failed',
                    subtitle: 'Google Sign-In failed. Please try again.',
                  );
                }
              }
            }
          },
        ),
        const SizedBox(height: 30),
        Text(
          'Don\'t want to create an account?',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal),
        ),
        SizedBox(height: 10),
        CustomTextButton(
          inkwellText: 'Continue as Guest',
          onTapAction: () {
            Hive.box('auth_box').put('triggerGuestAnimation', true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class SignUp extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final VoidCallback onTapAction;

  const SignUp({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.onTapAction,
  });

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseServices _authService = FirebaseServices();

  String passwordText = '';
  bool invalidInput = false;
  bool hasStrongPassword = false;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  Timer? _debounce;
  bool _isUsernameTaken = false;
  bool _isEmailTaken = false;
  String? _submitEmailError;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        CustomTextField(
          inputLabel: 'USERNAME',
          inputHint: 'Enter your username',
          inputType: TextInputType.text,
          controller: widget.usernameController,
          validator: (value) {
            if (value.isEmpty || value.trim().length < 8) {
              return value.isEmpty
                  ? 'Please fill the required field.'
                  : 'Username must be at least 8 characters.';
            }
            if (_isUsernameTaken) {
              return 'This username is already taken.';
            }
            return null;
          },
          onChanged: (value) {
            setState(() => invalidInput = false);

            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 300), () async {
              if (value.trim().length >= 8) {
                bool taken = await _authService.isUsernameTaken(value.trim());
                setState(() => _isUsernameTaken = taken);
              }
            });
          },
          forceValidate: invalidInput || _isUsernameTaken,
        ),
        SizedBox(height: 20),
        CustomTextField(
          inputLabel: 'EMAIL ADDRESS',
          inputHint: 'Enter your email',
          inputType: TextInputType.emailAddress,
          controller: widget.emailController,
          validator: (value) {
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (value.isEmpty || !emailRegex.hasMatch(value.trim())) {
              return value.isEmpty
                  ? 'Please fill the required field.'
                  : 'Please enter a valid email (e.g., name@example.com).';
            }
            if (_isEmailTaken) {
              return 'This email is already registered.';
            }
            if (_submitEmailError != null) {
              return _submitEmailError;
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              invalidInput = false;
              _submitEmailError = null;
            });

            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 300), () async {
              if (value.trim().length >= 8) {
                bool taken = false;
                try {
                  taken = await _authService.isEmailRegistered(value.trim());
                } catch (e) {
                  taken = false;
                }
                setState(() => _isEmailTaken = taken);
              }
            });
          },
          forceValidate:
              invalidInput || _isEmailTaken || _submitEmailError != null,
        ),
        SizedBox(height: 20),
        CustomTextField(
          inputLabel: 'PASSWORD',
          inputHint: 'Enter your password',
          inputType: TextInputType.visiblePassword,
          isPassword: true,
          isLoginPass: false,
          controller: widget.passwordController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please fill the required field.';
            }
            bool hasLength = value.length >= 8;
            bool hasSymbol = RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value);
            bool hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
            bool hasNumber = RegExp(r'[0-9]').hasMatch(value);

            int score =
                (hasLength ? 1 : 0) +
                (hasSymbol ? 1 : 0) +
                (hasUppercase ? 1 : 0) +
                (hasNumber ? 1 : 0);

            if (score < 4) {
              return 'Please meet all the password requirements.';
            }
            hasStrongPassword = true;
            return null;
          },
          onChanged: (value) {
            setState(() {
              passwordText = value;
              invalidInput = false;
            });
          },
          forceValidate: invalidInput,
          receivedPassword: passwordText,
        ),
        SizedBox(height: 20),
        CustomTextField(
          inputLabel: 'CONFIRM PASSWORD',
          inputHint: 'Confirm your password',
          inputType: TextInputType.visiblePassword,
          isPassword: true,
          isLoginPass: false,
          controller: widget.confirmController,
          validator: (value) {
            if (value.isEmpty || value != widget.passwordController.text) {
              return value.isEmpty
                  ? 'Please fill the required field.'
                  : 'Passwords do not match. Please try again.';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              invalidInput = false;
            });
          },
          forceValidate: invalidInput,
        ),
        SizedBox(height: 40),

        CustomButton(
          buttonText: 'Sign Up',
          isLoading: _isEmailLoading,
          isButtonEnabled:
              widget.usernameController.text.isNotEmpty &&
              widget.emailController.text.isNotEmpty &&
              widget.passwordController.text.isNotEmpty &&
              widget.confirmController.text.isNotEmpty,
          onTapAction: () async {
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            bool isUsernameValid =
                widget.usernameController.text.trim().length >= 8;
            bool isEmailValid = emailRegex.hasMatch(
              widget.emailController.text.trim(),
            );
            bool isPasswordValid =
                widget.passwordController.text.isNotEmpty && hasStrongPassword;
            bool isConfirmValid =
                widget.confirmController.text.isNotEmpty &&
                widget.confirmController.text == widget.passwordController.text;

            if (!isUsernameValid ||
                !isEmailValid ||
                !isPasswordValid ||
                !isConfirmValid) {
              setState(() {
                invalidInput = true;
              });
              return;
            }

            final settings = Provider.of<SettingsProvider>(
              context,
              listen: false,
            );

            try {
              settings.setPauseUpdates(true);
              setState(() => _isEmailLoading = true);

              await _authService.signUp(
                widget.emailController.text.trim(),
                widget.passwordController.text.trim(),
                widget.usernameController.text.trim(),
              );

              if (mounted) {
                setState(() => _isEmailLoading = false);
                AuthSuccessModal.show(
                  context,
                  title: 'Account Created!',
                  subtitle: 'Welcome to DocsEase.',
                  onPrimary: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    settings.setPauseUpdates(false);
                  },
                );
              }
            } catch (e) {
              settings.setPauseUpdates(false);
              if (mounted) {
                setState(() {
                  _isEmailLoading = false;
                  if (e is FirebaseAuthException &&
                      e.code == 'email-already-in-use') {
                    _submitEmailError = 'This email is already registered.';
                  } else {
                    invalidInput = true;
                  }
                });
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
          isLoading: _isGoogleLoading,
          onTapAction: () async {
            final settings = Provider.of<SettingsProvider>(
              context,
              listen: false,
            );
            try {
              setState(() => _isGoogleLoading = true);

              final GoogleSignIn googleSignIn = GoogleSignIn();
              await googleSignIn.signOut();
              final googleUser = await googleSignIn.signIn();

              if (googleUser == null) {
                if (mounted) setState(() => _isGoogleLoading = false);
                return;
              }

              settings.setPauseUpdates(true);

              final authService = FirebaseServices();
              final result = await authService.signUpWithGoogle(
                googleUser: googleUser,
              );

              if (mounted) {
                setState(() => _isGoogleLoading = false);

                if (result != null) {
                  AuthSuccessModal.show(
                    context,
                    title: 'Account Created!',
                    subtitle: 'Welcome to DocsEase.',
                    onPrimary: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      settings.setPauseUpdates(false);
                    },
                  );
                } else {
                  settings.setPauseUpdates(false);
                }
              }
            } catch (e) {
              settings.setPauseUpdates(false);
              if (mounted) {
                setState(() => _isGoogleLoading = false);

                if (e is GoogleAccountAlreadyUsedException) {
                  AuthErrorModal.show(
                    context,
                    title: 'Account Already Exists',
                    subtitle:
                        'This Google account is already used. Please sign in instead.',
                  );
                } else if (e is GoogleAccountIsAdminException) {
                  AuthErrorModal.show(
                    context,
                    title: 'Invalid Google Account',
                    subtitle: 'This Google account cannot be used to sign up.',
                  );
                } else {
                  AuthErrorModal.show(
                    context,
                    title: 'Sign Up Failed',
                    subtitle: 'Google Sign-Up failed. Please try again.',
                  );
                }
              }
            }
          },
        ),
        const SizedBox(height: 30),
        Text(
          'Don\'t want to create an account?',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal),
        ),
        SizedBox(height: 10),
        CustomTextButton(
          inkwellText: 'Continue as Guest',
          onTapAction: () {
            Hive.box('auth_box').put('triggerGuestAnimation', true);
            Navigator.pop(context);
          },
        ),
      ],
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
  final VoidCallback onTapAction;

  const CustomTextButton({
    super.key,
    required this.inkwellText,
    required this.onTapAction,
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
      onTap: widget.onTapAction,
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
            fontSize: 12,
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

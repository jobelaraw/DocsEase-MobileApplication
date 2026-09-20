import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docsease/custom_button.dart';
import 'package:docsease/custom_textfield.dart';
import 'package:docsease/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:docsease/app_modals.dart';
import 'package:docsease/main.dart' show navigatorKey;
import 'package:docsease/settings_provider.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseServices _editService = FirebaseServices();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String passwordText = '';
  bool hasStrongPassword = false;

  String currentEmail = 'Loading...';
  String currentUsername = 'Loading...';
  String currentProfile = 'assets/default_profile.png';

  bool invalidInput = false;
  bool isLoading = false;
  bool _isSaved = false;

  // Specific loading states for OTP actions to utilize button/inline indicators if needed
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;

  Timer? _debounce;
  bool _isUsernameTaken = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // OTP State Variables
  bool _isOtpSent = false;
  bool _isCodeVerified = false;
  int _resendSecondsLeft = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentEmail = user.email ?? "No Email";
      });
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              currentUsername = data['username'] ?? "Guest Account";
              currentProfile = data['profile_img'] ?? 'assets/default_profile.png';
            });
          }
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  void _startResendTimer() {
    setState(() => _resendSecondsLeft = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSecondsLeft = 0);
      } else {
        if (mounted) setState(() => _resendSecondsLeft--);
      }
    });
  }

  String _generateRecoveryCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<bool> _sendEmailJSRecovery(String targetEmail, String recoveryCode) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': 'service_e6xjj5b',
          'template_id': 'template_1u1on8f',
          'user_id': 'MhxD0XeexOnz61prP',
          'accessToken': 'ZwFXbNZRrkVkNGK4YFHWm',
          'template_params': {'to_email': targetEmail, 'recovery_code': recoveryCode},
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("EmailJS Error: $e");
      return false;
    }
  }

  Future<void> _sendCode() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;
    String targetEmail = user.email!;

    setState(() => _isSendingCode = true);
    try {
      String recoveryCode = _generateRecoveryCode();
      await FirebaseFirestore.instance.collection('recovery_codes').doc(targetEmail).set({
        'code': recoveryCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      bool emailSent = await _sendEmailJSRecovery(targetEmail, recoveryCode);
      if (!mounted) return;
      setState(() => _isSendingCode = false);

      if (emailSent) {
        setState(() {
          _isOtpSent = true;
        });
        _startResendTimer();
        CheckEmailModal.show(context, onPrimary: () => Navigator.of(context, rootNavigator: true).pop()); 
      } else {
        AuthErrorModal.show(context, title: 'Failed to Send', subtitle: 'Please check your internet connection.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingCode = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending code.')));
      }
    }
  }

  Future<void> _verifyCode() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _isVerifyingCode = true);
    try {
      var doc = await FirebaseFirestore.instance.collection('recovery_codes').doc(user.email!).get();
      if (!mounted) return;
      setState(() => _isVerifyingCode = false);

      if (doc.exists && doc.data()?['code'] == _otpController.text.trim()) {
        setState(() {
          _isCodeVerified = true;
          _resendTimer?.cancel();
        });
        VerifiedModal.show(context, onPrimary: () => Navigator.of(context, rootNavigator: true).pop());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid verification code.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifyingCode = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification error.')));
      }
    }
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color.fromRGBO(32, 87, 206, 1.0)),
                title: Text('Take a photo', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() => _selectedImage = File(photo.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color.fromRGBO(32, 87, 206, 1.0)),
                title: Text('Choose from gallery', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() => _selectedImage = File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasChanges =
        (_usernameController.text.isNotEmpty && _usernameController.text != currentUsername) ||
        _newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty ||
        _selectedImage != null;

    bool canVerify = _otpController.text.length == 6;
    bool canResend = _isOtpSent && _resendSecondsLeft == 0;
    
    String btnText = _isCodeVerified ? 'Verified' : (canVerify ? 'Verify Code' : (_isOtpSent ? 'Resend Code' : 'Send Code'));
    Color btnColor = _isCodeVerified ? Colors.green : (canVerify || !_isOtpSent || canResend ? const Color(0xFF2563EB) : Colors.grey.shade400);
    Color textColor = _isCodeVerified || canVerify || !_isOtpSent || canResend ? Colors.white : Colors.black54;

    return WillPopScope(
      onWillPop: () async {
        if (hasChanges && !_isSaved) {
          bool shouldLeave = false;
          await ProfileChangesModal.show(
            context,
            onPrimary: () {
              shouldLeave = true;
              Navigator.of(context, rootNavigator: true).pop();
            },
          );
          return shouldLeave;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primary,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: ClipOval(
                                child: _selectedImage != null
                                    ? Image.file(_selectedImage!, width: 95, height: 95, fit: BoxFit.cover)
                                    : currentProfile == 'assets/default_profile.png'
                                    ? Image.asset(currentProfile, width: 95, height: 95, fit: BoxFit.cover)
                                    : Image.network(currentProfile, width: 95, height: 95, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImagePickerOptions,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: Image.asset('assets/camera_icon.png', width: 20, height: 20, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          currentEmail,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Form Elements
              Stack(
                children: [
                  Container(
                    height: 50,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.tertiary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          inputLabel: 'USERNAME',
                          inputHint: currentUsername,
                          inputType: TextInputType.text,
                          isLoginPass: false,
                          isPassword: false,
                          controller: _usernameController,
                          validator: (value) {
                            if (value.isNotEmpty && value.trim().length < 8) return 'Username must be at least 8 characters.';
                            if (_isUsernameTaken && value.isNotEmpty) return 'This username is already taken.';
                            return null;
                          },
                          onChanged: (value) {
                            setState(() => invalidInput = false);
                            if (_debounce?.isActive ?? false) _debounce!.cancel();
                            _debounce = Timer(const Duration(milliseconds: 300), () async {
                              if (value.trim().length >= 8) {
                                bool taken = await _editService.isUsernameTaken(value.trim());
                                setState(() => _isUsernameTaken = taken);
                              }
                            });
                          },
                          forceValidate: invalidInput || _isUsernameTaken,
                        ),
                        const SizedBox(height: 20),

                        // Locked Password Fields
                        Opacity(
                          opacity: _isCodeVerified ? 1.0 : 0.4,
                          child: IgnorePointer(
                            ignoring: !_isCodeVerified,
                            child: Column(
                              children: [
                                CustomTextField(
                                  inputLabel: 'NEW PASSWORD',
                                  inputHint: 'Enter your password',
                                  inputType: TextInputType.visiblePassword,
                                  isPassword: true,
                                  isLoginPass: false,
                                  controller: _newPasswordController,
                                  validator: (value) {
                                    if (value.isEmpty) return null;
                                    bool hasLength = value.length >= 8;
                                    bool hasSymbol = RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value);
                                    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
                                    bool hasNumber = RegExp(r'[0-9]').hasMatch(value);
                                    int score = (hasLength ? 1 : 0) + (hasSymbol ? 1 : 0) + (hasUppercase ? 1 : 0) + (hasNumber ? 1 : 0);
                                    if (score < 4) return 'Please meet all the password requirements.';
                                    hasStrongPassword = true;
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() { passwordText = value; invalidInput = false; });
                                  },
                                  forceValidate: invalidInput,
                                  receivedPassword: passwordText,
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  inputLabel: 'CONFIRM PASSWORD',
                                  inputHint: 'Confirm your password',
                                  inputType: TextInputType.visiblePassword,
                                  isPassword: true,
                                  isLoginPass: false,
                                  controller: _confirmPasswordController,
                                  validator: (value) {
                                    if (value != _newPasswordController.text) return 'Passwords do not match.';
                                    return null;
                                  },
                                  onChanged: (value) => setState(() => invalidInput = false),
                                  forceValidate: invalidInput,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // OTP Verification Row
                        Text(
                          'VERIFICATION CODE',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _otpController,
                                  enabled: !_isCodeVerified,
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.characters,
                                  maxLength: 6,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
                                  onChanged: (val) {
                                    setState(() {}); 
                                  },
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                    hintText: '000000',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 42,
                              width: 115,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: btnColor,
                                  foregroundColor: textColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: (_isSendingCode || _isVerifyingCode) ? null : (_isCodeVerified ? null : (canVerify ? _verifyCode : ((!_isOtpSent || canResend) ? _sendCode : null))),
                                child: (_isSendingCode || _isVerifyingCode)
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(
                                        btnText,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        if (_isOtpSent && !_isCodeVerified)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Center(
                              child: Text(
                                '00:${_resendSecondsLeft.toString().padLeft(2, '0')}',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),

                        // Save Changes Button
                        CustomButton(
                          buttonText: 'Save Changes',
                          isLoading: isLoading,
                          isButtonEnabled: _usernameController.text.isNotEmpty || (_isCodeVerified && _newPasswordController.text.isNotEmpty && _confirmPasswordController.text.isNotEmpty) || _selectedImage != null,
                          btnElevation: 4,
                          btnRadius: 15,
                          onTapAction: () async {
                            await ConfirmChangesModal.show(
                              context,
                              onPrimary: () async {
                                Navigator.of(context, rootNavigator: true).pop();

                                bool isUpdatingPassword = _isCodeVerified && _newPasswordController.text.isNotEmpty;
                                if (isUpdatingPassword) {
                                  bool isPasswordValid = _newPasswordController.text.isNotEmpty && hasStrongPassword;
                                  bool isConfirmValid = _confirmPasswordController.text.isNotEmpty && _confirmPasswordController.text == _newPasswordController.text;

                                  if (!isPasswordValid || !isConfirmValid) {
                                    setState(() => invalidInput = true);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please check your password details.")));
                                    return;
                                  }
                                }

                                try {
                                  setState(() => isLoading = true);
                                  User? currentUser = FirebaseAuth.instance.currentUser;
                                  if (currentUser == null) throw Exception("User not logged in");

                                  String? newImageUrl;
                                  if (_selectedImage != null) {
                                    newImageUrl = await _editService.uploadProfileImage(_selectedImage!, currentUser.uid);
                                    if (currentProfile != 'assets/default_profile.png' && currentProfile.isNotEmpty) {
                                      await _editService.deleteOldProfileImage(currentProfile);
                                    }
                                  }

                                  await _editService.updateUserProfile(
                                    newUsername: _usernameController.text.trim(),
                                    newPassword: isUpdatingPassword ? _newPasswordController.text.trim() : null,
                                    newProfileImgUrl: newImageUrl,
                                  );

                                  if (isUpdatingPassword && currentUser.email != null) {
                                    await FirebaseFirestore.instance
                                        .collection('recovery_codes')
                                        .doc(currentUser.email)
                                        .delete();
                                  }

                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                      _isSaved = true;
                                    });
                                    ChangesSavedModal.show(
                                      context,
                                      onPrimary: () {
                                        Navigator.of(context, rootNavigator: true).pop();
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() { invalidInput = true; isLoading = false; });
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Delete Account
              Column(
                children: [
                  Text('Do you want to delete your account?', style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () async {
                      DeleteAccountModal.show(
                        context,
                        onPrimary: () async {
                          Navigator.of(context, rootNavigator: true).pop();

                          try {
                            await _editService.deleteAccount();

                            if (mounted) {
                              await Provider.of<SettingsProvider>(
                                context,
                                listen: false,
                              ).loadSettings();
                            }

                            if (mounted) {
                              AuthSuccessModal.show(
                                context,
                                title: 'Account Deleted',
                                subtitle: 'Your account have been successfully deleted.',
                                onPrimary: () {
                                  navigatorKey.currentState?.popUntil((route) => route.isFirst);
                                },
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              AuthErrorModal.show(context, title: 'Deletion Failed', subtitle: 'Please sign out and sign back in before deleting your account.');
                            }
                          }
                        },
                      );
                    },
                    child: Text('Delete Account', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
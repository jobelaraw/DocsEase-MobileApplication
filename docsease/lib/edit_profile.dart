import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docsease/custom_button.dart';
import 'package:docsease/custom_textfield.dart';
import 'package:docsease/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

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

  String passwordText = '';
  bool hasStrongPassword = false;

  String currentEmail = 'Loading...';
  String currentUsername = 'Loading...';
  String currentProfile = 'assets/default_profile.png';

  bool invalidInput = false;
  bool isLoading = false;

  Timer? _debounce;
  bool _isUsernameTaken = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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
                  Navigator.pop(context); // Close the bottom sheet
                  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() {
                      _selectedImage = File(photo.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color.fromRGBO(32, 87, 206, 1.0)),
                title: Text(
                  'Choose from gallery',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // The email is guaranteed to be in the Auth token
      setState(() {
        currentEmail = user.email ?? "No Email";
      });

      try {
        // Fetch the rest of the custom profile from Firestore
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(230, 246, 255, 1.0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue Header Section
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  width: double.infinity,
                  color: const Color.fromRGBO(32, 87, 206, 1.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      width: 95,
                                      height: 95,
                                      fit: BoxFit.cover,
                                    )
                                  : currentProfile == 'assets/default_profile.png'
                                  ? Image.asset(
                                      currentProfile,
                                      width: 95,
                                      height: 95,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      currentProfile,
                                      width: 95,
                                      height: 95,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                _showImagePickerOptions();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  // color: Color.fromRGBO(99, 136, 224, 1),
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/camera_icon.png',
                                  width: 20,
                                  height: 20,
                                  color: Colors.black,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        currentEmail,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Edit Form Card
            Stack(
              children: [
                Container(
                  height: 50,
                  width: double.infinity,
                  color: const Color.fromRGBO(32, 87, 206, 1.0),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
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
                          if (value.isNotEmpty && value.trim().length < 8) {
                            return 'Username must be at least 8 characters.';
                          }
                          if (_isUsernameTaken && value.isNotEmpty) {
                            return 'This username is already taken.';
                          }
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
                      CustomTextField(
                        inputLabel: 'PASSWORD',
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
                      const SizedBox(height: 20),
                      CustomTextField(
                        inputLabel: 'CONFIRM PASSWORD',
                        inputHint: 'Confirm your password',
                        inputType: TextInputType.visiblePassword,
                        isPassword: true,
                        isLoginPass: false,
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match. Please try again.';
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
                      const SizedBox(height: 30),
                      CustomButton(
                        buttonText: 'Save Changes',
                        isLoading: isLoading,
                        isButtonEnabled:
                            _usernameController.text.isNotEmpty ||
                            _newPasswordController.text.isNotEmpty ||
                            _confirmPasswordController.text.isNotEmpty ||
                            _selectedImage != null,
                        btnElevation: 4,
                        btnRadius: 15,
                        onTapAction: () async {
                          bool isUpdatingPassword =
                              _newPasswordController.text.isNotEmpty ||
                              _confirmPasswordController.text.isNotEmpty;

                          if (isUpdatingPassword) {
                            bool isPasswordValid =
                                _newPasswordController.text.isNotEmpty && hasStrongPassword;
                            bool isConfirmValid =
                                _confirmPasswordController.text.isNotEmpty &&
                                _confirmPasswordController.text == _newPasswordController.text;

                            if (!isPasswordValid || !isConfirmValid) {
                              setState(() => invalidInput = true);
                              return;
                            }
                          }

                          try {
                            setState(() => isLoading = true);

                            User? currentUser = FirebaseAuth.instance.currentUser;
                            if (currentUser == null) throw Exception("User not logged in");

                            String? newImageUrl;
                            if (_selectedImage != null) {
                              newImageUrl = await _editService.uploadProfileImage(
                                _selectedImage!,
                                currentUser.uid,
                              );

                              if (currentProfile != 'assets/default_profile.png' &&
                                  currentProfile.isNotEmpty) {
                                await _editService.deleteOldProfileImage(currentProfile);
                              }
                            }

                            await _editService.updateUserProfile(
                              newUsername: _usernameController.text.trim(),
                              newPassword: _newPasswordController.text.trim(),
                              newProfileImgUrl: newImageUrl,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                invalidInput = true;
                                isLoading = false;
                              });
                              // ScaffoldMessenger.of(
                              //   context,
                              // ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

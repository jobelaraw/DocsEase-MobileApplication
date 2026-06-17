

import 'package:docsease/app_start.dart';
import 'package:docsease/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:docsease/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // This is required for Firebase and other plugins to work properly

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    // Initialize Firebase using the file you generated
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => SettingsProvider()..loadSettings(),
        child: const MyApp(),
      ),
    );
  });
}

// This is for running the start of the application; for now, it's the services.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Consumer listens to the broadcast and rebuilds MaterialApp when settings change
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // Calculate font scale: 0.5 slider = 1.0 (normal size). 1.0 slider = 1.2 (large).
        double scaleFactor = 0.8 + (settings.fontSize * 0.4);

        return MaterialApp(
          debugShowMaterialGrid: false,

          // Global Dark Mode Control!
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Your Custom Light Theme (DocsEase Blue & White)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color.fromRGBO(
              235,
              243,
              255,
              1.0,
            ), // Light blue app background
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(32, 87, 206, 1.0), // DocsEase Blue (Headers, Buttons)
              secondary: Color.fromRGBO(59, 115, 224, 1.0), // Lighter Dark Blue (Highlight texts)
              tertiary: Color.fromRGBO(208, 236, 252, 1), // Lighter Blue (Container)
              surface: Colors.white, // Color of scaffol, cards and containers
              onPrimary: Colors.white, // Text color on top of primary buttons
              onSurface: Colors.black87, // Text color on top of cards/background
            ),
          ),

          // Your Custom Dark Theme (Deep Grays)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              primary: const Color (0XFF242424),// app bar and header background, slightly lighter than the scaffold to create depth
              secondary: Colors.black87, 
              tertiary: const Color (0XFF202020), 
              surface: const Color(0XFF121212),
              onPrimary: Colors.white, // Text color on top of primary buttons
              onSurface: Colors.white70, // Text color on top of dark cards
            ),
          ),

          title: 'DocsEase',
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scaleFactor)),
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: child!,
              ),
            );
          },
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        // While Firebase is checking the device's local storage for a token...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color.fromRGBO(32, 87, 206, 1.0),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        // If Firebase found a logged-in user...
        if (snapshot.hasData) {
          return const SideBar();
        }
        // If no user is logged in...
        return const AppStart();
      },
    );
  }
}
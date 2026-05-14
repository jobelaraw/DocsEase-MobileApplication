

import 'package:docsease/app_start.dart';
import 'package:docsease/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // This is required for Firebase and other plugins to work properly

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    // Initialize Firebase using the file you generated
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://qihfxsgdnapcipirbiep.supabase.co',
    anonKey: 'sb_publishable_r56F0TY29AmhmbkCHqPGXQ_MPErMRnC',
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const MyApp());
  });
}

// This is for running the start of the application; for now, it's the services.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocsEase',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);

        double scaleFactor = 1.0;

        if (mediaQueryData.size.width < 400) {
          scaleFactor = mediaQueryData.size.width / 400;
        }

        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: TextScaler.linear(scaleFactor)),
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

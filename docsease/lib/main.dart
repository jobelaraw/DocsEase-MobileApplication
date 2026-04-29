import 'package:docsease/app_start.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // This is required for Firebase and other plugins to work properly

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(   // Initialize Firebase using the file you generated
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// This is for running the start of the application; for now, it's the services.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'DocsEase',
        debugShowCheckedModeBanner: false, home: const AppStart());
  }
}

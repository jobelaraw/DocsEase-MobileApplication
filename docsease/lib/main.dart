import 'package:docsease/app_start.dart';
import 'package:docsease/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:docsease/settings_provider.dart';

Future<void> main() async {
  // 1. Lock the splash screen to the screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 2. Do the fast 300ms background loading
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('auth_box');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => SettingsProvider()..loadSettings(),
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        double scaleFactor = 0.8 + (settings.fontSize * 0.4);

        return MaterialApp(
          debugShowMaterialGrid: false,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color.fromRGBO(235, 243, 255, 1.0),
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(32, 87, 206, 1.0),
              secondary: Color.fromRGBO(59, 115, 224, 1.0),
              tertiary: Color.fromRGBO(208, 236, 252, 1),
              surface: Colors.white,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              primary: Color(0XFF242424),
              secondary: Colors.black87,
              tertiary: Color(0XFF202020),
              surface: Color(0XFF121212),
              onPrimary: Colors.white,
              onSurface: Colors.white70,
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
        // Wait for Firebase to finish checking the login state
        if (snapshot.connectionState == ConnectionState.waiting) {
          // We just return an empty container because the Native Splash Screen is still perfectly covering the screen!
          return const SizedBox();
        }

        // The exact millisecond we know where to send the user, remove the splash screen!
        FlutterNativeSplash.remove();

        // User is registered
        if (snapshot.hasData) {
          return const SideBar();
        }

        // User continued as guest
        var authBox = Hive.box('auth_box');
        bool isGuest = authBox.get('continueGuest', defaultValue: false);
        if (isGuest) {
          return const SideBar(isGuest: true); // Auto-login the guest
        }

        return const AppStart();
      },
    );
  }
}

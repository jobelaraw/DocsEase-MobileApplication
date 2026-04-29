import 'package:docsease/app_start.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

// This is for running the start of the application; for now, it's the services.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocsEase',
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);

        double scaleFactor = 1.0;

        if (mediaQueryData.size.width < 400) {
          scaleFactor = mediaQueryData.size.width / 400;
        }

        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(scaleFactor),
          ),
          child: child!,
        );
      },
      home: const AppStart(),
    );
  }
}

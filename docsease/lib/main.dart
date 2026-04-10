import 'package:flutter/material.dart';
import 'package:docsease/side_bar.dart';

void main() {
  runApp(const MyApp());
}

// This is for running the start of the application; for now, it's the services.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'DocsEase', home: SideBar());
  }
}

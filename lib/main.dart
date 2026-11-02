import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'login_page.dart';
import 'ui_effects.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MYDVAN',

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),

      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,

        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            for (final platform in TargetPlatform.values)
              platform: const FadeSlideTransitionsBuilder(),
          },
        ),
      ),

      home: const LoginPage(),
    );
  }
}

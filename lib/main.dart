import 'package:flutter/material.dart';
import 'package:noise_app/routes.dart';
import 'package:noise_app/theme/style.dart';

void main() {
  runApp(NoiseApp());
}

class NoiseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noise App',
      theme: appTheme(),
      initialRoute: '/',
      routes: routes,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:noise_app/screens/home/homescreen.dart';
import 'package:noise_app/screens/settings/settingsscreen.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/": (BuildContext context) => HomeScreen(),
  "/settings": (BuildContext context) => SettingsScreen(),
};

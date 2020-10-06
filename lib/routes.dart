import 'package:flutter/material.dart';
import 'package:noise_app/screens/about/aboutscreen.dart';
import 'package:noise_app/screens/help/helpscreen.dart';
import 'package:noise_app/screens/home/homescreen.dart';
import 'package:noise_app/screens/tools/toolsscreen.dart';
import 'package:noise_app/screens/settings/settingsscreen.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/": (BuildContext context) => HomeScreen(),
  "/tools": (BuildContext context) => ToolsScreen(),
  "/settings": (BuildContext context) => SettingsScreen(),
  "/help": (BuildContext context) => HelpScreen(),
  "/about": (BuildContext context) => AboutScreen()
};

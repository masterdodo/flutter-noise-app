import 'package:flutter/material.dart';
import 'package:noise_app/screens/home/homescreen.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/": (BuildContext context) => HomeScreen(),
};

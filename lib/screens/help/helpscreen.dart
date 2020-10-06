import 'package:flutter/material.dart';
import 'package:noise_app/app_localizations.dart';
import 'package:noise_app/components/my_drawer.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  Color _bgColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('help_string')),
      ),
      body: Text("Help"),
    );
  }
}

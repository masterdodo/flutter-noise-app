import 'package:flutter/material.dart';
import 'package:noise_app/app_localizations.dart';
import 'package:noise_app/components/my_drawer.dart';

class ToolsScreen extends StatefulWidget {
  @override
  _ToolsScreenState createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  Color _bgColor = Colors.white;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      drawer: MyDrawer(),
      appBar: AppBar(
          title: Text(
              AppLocalizations.of(context).translate('menu_tools_string'))),
      body: null,
    );
  }
}

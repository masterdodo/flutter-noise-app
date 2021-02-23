import 'package:flutter/material.dart';
import 'package:noise_app/app_localizations.dart';
import 'package:noise_app/components/my_drawer.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Color _bgColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/");
        return false;
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        drawer: MyDrawer(),
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('about_string')),
        ),
        body: Text("About"),
      ),
    );
  }
}

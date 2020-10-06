import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_localizations.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: null,
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            selected: (ModalRoute.of(context).settings.name == '/'),
            title: Text(
                AppLocalizations.of(context).translate('menu_home_string')),
            leading: Icon(Icons.home),
            onTap: () {
              if (ModalRoute.of(context).settings.name == '/') {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              }
            },
          ),
          ListTile(
            selected: (ModalRoute.of(context).settings.name == '/tools'),
            title: Text(
                AppLocalizations.of(context).translate('menu_tools_string')),
            leading: Icon(Icons.build),
            onTap: () {
              if (ModalRoute.of(context).settings.name == '/tools') {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tools');
              }
            },
          ),
          ListTile(
            selected: (ModalRoute.of(context).settings.name == '/settings'),
            title: Text(
                AppLocalizations.of(context).translate('menu_settings_string')),
            leading: Icon(Icons.settings),
            onTap: () {
              if (ModalRoute.of(context).settings.name == '/settings') {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              }
            },
          ),
          ListTile(
            selected: (ModalRoute.of(context).settings.name == '/help'),
            title: Text(AppLocalizations.of(context).translate('help_string')),
            leading: Icon(Icons.help),
            onTap: () {
              if (ModalRoute.of(context).settings.name == '/help') {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/help');
              }
            },
          ),
          ListTile(
            selected: (ModalRoute.of(context).settings.name == '/about'),
            title: Text(AppLocalizations.of(context).translate('about_string')),
            leading: Icon(Icons.question_answer),
            onTap: () {
              if (ModalRoute.of(context).settings.name == '/about') {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              }
            },
          ),
          Divider(
            color: Colors.grey,
            height: 30,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(AppLocalizations.of(context).translate('exit_string')),
            onTap: () => SystemNavigator.pop(),
          ),
        ],
      ),
    );
  }
}

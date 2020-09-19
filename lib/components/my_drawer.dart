import 'package:flutter/material.dart';

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
          )
        ],
      ),
    );
  }
}

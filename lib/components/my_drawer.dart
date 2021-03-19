import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import '../app_localizations.dart';

class MyDrawer extends StatelessWidget {
  final VoidCallback stopSound;

  MyDrawer({this.stopSound});

  void sendMail(context) async {
    final Email email = Email(
      body: AppLocalizations.of(context).translate('hello_string') +
          "!\n" +
          AppLocalizations.of(context).translate('email_string') +
          "\n\n",
      subject: AppLocalizations.of(context).translate('email_title_string'),
      recipients: ['snorty@j-lab.si'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

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
                if (ModalRoute.of(context).settings.name == '/tools') {
                  stopSound();
                }

                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
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
                Navigator.pushReplacementNamed(context, '/tools');
              }
            },
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context).translate("archive_string"),
              style: TextStyle(color: Colors.grey[400]),
            ),
            leading: Icon(
              Icons.archive,
              color: Colors.grey[400],
            ),
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
                if (ModalRoute.of(context).settings.name == '/tools') {
                  stopSound();
                }

                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/settings');
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
                if (ModalRoute.of(context).settings.name == '/tools') {
                  stopSound();
                }

                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/help');
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
                if (ModalRoute.of(context).settings.name == '/tools') {
                  stopSound();
                }

                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/about');
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  if (ModalRoute.of(context).settings.name == '/tools') {
                    stopSound();
                  }
                  /*Share.share(
                      AppLocalizations.of(context).translate('share_string'));*/
                },
                child: Row(
                  children: [
                    Icon(Icons.share),
                    Text(AppLocalizations.of(context)
                        .translate('share_menu_string'))
                  ],
                ),
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.black)),
              ),
              TextButton(
                onPressed: () {
                  if (ModalRoute.of(context).settings.name == '/tools') {
                    stopSound();
                  }
                  sendMail(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.email),
                    Text(AppLocalizations.of(context)
                        .translate('email_menu_string'))
                  ],
                ),
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.black)),
              )
            ],
          ),
          Divider(
            color: Colors.grey,
            height: 30,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(AppLocalizations.of(context).translate('exit_string')),
            onTap: () {
              if (ModalRoute.of(context).settings.name == '/tools') {
                stopSound();
              }
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          ),
        ],
      ),
    );
  }
}

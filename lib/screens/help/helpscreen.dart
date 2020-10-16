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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('help_intro_string'),
                style: TextStyle(fontSize: 18),
              ),
              Divider(
                color: Colors.transparent,
              ),
              Text(
                AppLocalizations.of(context).translate('settings_string') + ":",
                style: TextStyle(fontSize: 22),
              ),
              Divider(
                color: Colors.transparent,
              ),
              Text(
                "1. " +
                    AppLocalizations.of(context)
                        .translate('db_treshold_string') +
                    "\n" +
                    AppLocalizations.of(context)
                        .translate('db_treshold_help_string'),
                style: TextStyle(fontSize: 18),
              ),
              Divider(
                color: Colors.transparent,
              ),
              Text(
                "2. " +
                    AppLocalizations.of(context).translate('per_sec_string') +
                    "\n" +
                    AppLocalizations.of(context)
                        .translate('per_sec_help_string'),
                style: TextStyle(fontSize: 18),
              ),
              Divider(
                color: Colors.transparent,
              ),
              Text(
                "3. " +
                    AppLocalizations.of(context)
                        .translate('time_frame_string') +
                    "\n" +
                    AppLocalizations.of(context)
                        .translate('time_frame_help_string'),
                style: TextStyle(fontSize: 18),
              ),
              Divider(
                color: Colors.transparent,
              ),
              Text(
                "4. " +
                    AppLocalizations.of(context).translate('timeout_string') +
                    "\n" +
                    AppLocalizations.of(context)
                        .translate('timeout_help_string'),
                style: TextStyle(fontSize: 18),
              ),
              Divider(
                color: Colors.transparent,
              ),
              Text(
                "5. " +
                    AppLocalizations.of(context).translate('audio_string') +
                    "\n" +
                    AppLocalizations.of(context).translate('audio_help_string'),
                style: TextStyle(fontSize: 18),
              ),
              Divider(
                color: Colors.transparent,
              ),
              Text(
                "6. " +
                    AppLocalizations.of(context)
                        .translate('sound_volume_string') +
                    "\n" +
                    AppLocalizations.of(context)
                        .translate('sound_volume_help_string'),
                style: TextStyle(fontSize: 18),
              ),
              Divider(
                color: Colors.transparent,
              ),
              Text(
                "7. " +
                    AppLocalizations.of(context)
                        .translate('sound_volume_string') +
                    "\n" +
                    AppLocalizations.of(context)
                        .translate('on_off_help_string'),
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

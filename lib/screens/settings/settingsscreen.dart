import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:noise_app/components/my_drawer.dart';
import 'package:noise_app/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final audioString = "Choose audio file...";

  Timer timer; //timer used for persec dB checks

  Color _bgColor = Colors.white; //default bg color of app
  // _current - realtime values of sliders, active - values after recoding started
  int _currentDbValue,
      _currentPerSecValue,
      _currentTimeSampleValue,
      _currentAudioVolumeValue,
      _currentTimeoutValue;

  double _dbMinValue = 35;
  double _dbMaxValue = 150;
  double _perSecMinValue = 1;
  double _perSecMaxValue = 60;
  double _timeSampleMinValue = 1;
  double _timeSampleMaxValue = 60;
  double _timeoutMinValue = 1;
  double _timeoutMaxValue = 60;
  double _audioVolumeMinValue = 1;
  double _audioVolumeMaxValue = 100;

  bool _advancedSettings = false;
  bool _settingsChanged = false;
  bool _audioActive1 = true;
  bool _audioActive2 = false;
  bool _audioActive3 = false;
  bool _audio1Playing = false;
  bool _audio2Playing = false;
  bool _audio3Playing = false;
  bool _algorithmValue = false;
  bool _scheduleValue = false;
  bool _hourlyValue = false;
  bool _footageValue = false;

  bool _proVersion = false;

  String _persecUnit = "sec";
  String _timesampleUnit = "sec";
  String _timeoutUnit = "sec";

  final dbTresholdController = TextEditingController();
  final perSecController = TextEditingController();
  final timeSampleController = TextEditingController();
  final timeoutController = TextEditingController();
  final audioVolumeController = TextEditingController();

  String _currentAudioName1; //current audio name 1
  String _currentAudioName2; //current audio name 2
  String _currentAudioName3; //current audio name 3

  final assetPlayer = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer();

  Map<String, int> _defaultSounds = {
    "audio/Bleep.mp3": 2,
    "audio/Censor-beep-3.mp3": 1,
    "audio/Foghorn.mp3": 5,
    "audio/Grocery-Scanning.mp3": 4,
    "audio/Snort-1.mp3": 4,
    "audio/Snort-2.mp3": 2,
    "audio/Snort-3.mp3": 7
  };

  @override
  void initState() {
    super.initState();
    loadingVarsAsync();
  }

  @override
  void dispose() {
    super.dispose();
    dbTresholdController.dispose();
    perSecController.dispose();
    timeSampleController.dispose();
    timeoutController.dispose();
    audioVolumeController.dispose();
  }

  void loadingVarsAsync() async {
    await getSharedPrefs();
    dbTresholdController.addListener(_setDbTresholdValue);
    perSecController.addListener(_setPerSecValue);
    timeSampleController.addListener(_setTimeSampleValue);
    timeoutController.addListener(_setTimeoutValue);
    audioVolumeController.addListener(_setAudioVolumeValue);
    _settingsChanged = false;
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentDbValue = prefs.getInt("dbValue") ?? 30;
      _currentPerSecValue = prefs.getInt("persecValue") ?? 1;
      _currentTimeSampleValue = prefs.getInt("timesampleValue") ?? 1;
      _currentTimeoutValue = prefs.getInt("timeoutValue") ?? 1;
      _currentAudioVolumeValue = prefs.getInt("audiovolumeValue") ?? 100;
      dbTresholdController.text = _currentDbValue.round().toString();
      perSecController.text = _currentPerSecValue.round().toString();
      timeSampleController.text = _currentTimeSampleValue.round().toString();
      timeoutController.text = _currentTimeoutValue.round().toString();
      audioVolumeController.text = _currentAudioVolumeValue.round().toString();
      _currentAudioName1 = prefs.getString("audioname1Value") ?? audioString;
      _audioActive1 = prefs.getBool("audioActive1") ?? true;
      _currentAudioName2 = prefs.getString("audioname2Value") ?? audioString;
      _audioActive2 = prefs.getBool("audioActive2") ?? false;
      _currentAudioName3 = prefs.getString("audioname3Value") ?? audioString;
      _audioActive3 = prefs.getBool("audioActive3") ?? false;
      _persecUnit = prefs.getString("persecUnit") ?? 'sec';
      _timesampleUnit = prefs.getString("timesampleUnit") ?? 'sec';
      _timeoutUnit = prefs.getString("timeoutUnit") ?? 'sec';
      _algorithmValue = prefs.getBool("algorithmValue") ?? false;
      _scheduleValue = prefs.getBool("scheduleValue") ?? false;
      _hourlyValue = prefs.getBool("hourlyValue") ?? false;
      _footageValue = prefs.getBool("footageValue") ?? false;
    });
  }

  _setDbTresholdValue() {
    if (double.parse(dbTresholdController.text).roundToDouble() >=
            _dbMinValue &&
        double.parse(dbTresholdController.text).roundToDouble() <=
            _dbMaxValue) {
      setState(() {
        _currentDbValue = double.parse(dbTresholdController.text).round();
        _settingsChanged = true;
      });
    }
  }

  _setPerSecValue() {
    if (double.parse(perSecController.text).roundToDouble() >=
            _perSecMinValue &&
        double.parse(perSecController.text).roundToDouble() <=
            _perSecMaxValue) {
      setState(() {
        _currentPerSecValue = double.parse(perSecController.text).round();
        _settingsChanged = true;
      });
    }
  }

  _setTimeSampleValue() {
    if (double.parse(timeSampleController.text).roundToDouble() >=
            _timeSampleMinValue &&
        double.parse(timeSampleController.text).roundToDouble() <=
            _timeSampleMaxValue) {
      setState(() {
        _currentTimeSampleValue =
            double.parse(timeSampleController.text).round();
        _settingsChanged = true;
      });
    }
  }

  _setTimeoutValue() {
    if (double.parse(timeoutController.text).roundToDouble() >=
            _timeoutMinValue &&
        double.parse(timeoutController.text).roundToDouble() <=
            _timeoutMaxValue) {
      setState(() {
        _currentTimeoutValue = double.parse(timeoutController.text).round();
        _settingsChanged = true;
      });
    }
  }

  _setAudioVolumeValue() {
    if (double.parse(audioVolumeController.text).roundToDouble() >=
            _audioVolumeMinValue &&
        double.parse(audioVolumeController.text).roundToDouble() <=
            _audioVolumeMaxValue) {
      setState(() {
        _currentAudioVolumeValue =
            double.parse(audioVolumeController.text).round();
        _settingsChanged = true;
      });
    }
  }

  _setscheduleValue() {
    setState(() {
      _scheduleValue = !_scheduleValue;
      _settingsChanged = true;
    });
  }

  _setAlgorithmValue() {
    setState(() {
      _algorithmValue = !_algorithmValue;
      if (!_algorithmValue) {
        _audioActive1 = true;
        _audioActive2 = false;
        _audioActive3 = false;
      }
      _settingsChanged = true;
    });
  }

  _setHourlyValue() {
    setState(() {
      _hourlyValue = !_hourlyValue;
      _settingsChanged = true;
    });
  }

  _setFootageValue() {
    setState(() {
      _footageValue = !_footageValue;
      _settingsChanged = true;
    });
  }

  showAlertDialog1(BuildContext context) async {
    // set up the buttons
    Widget assetsButton = TextButton(
      child:
          Text(AppLocalizations.of(context).translate('default_sounds_string')),
      onPressed: () async {
        Navigator.of(context).pop();
        String _audioPath = await showDefaultSoundDialog(context);
        if (_audioPath != null) {
          setState(() {
            _currentAudioName1 = _audioPath;
            _settingsChanged = true;
          });
        }
      },
    );
    Widget localButton = TextButton(
      child: Text(AppLocalizations.of(context).translate('choose_string')),
      onPressed: () async {
        Navigator.of(context).pop();
        String _audioPath = await openAudioPicker();
        if (_audioPath != null) {
          setState(() {
            _currentAudioName1 = _audioPath;
            _settingsChanged = true;
          });
        }
      },
    );
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).translate('cancel_string')),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title:
          Text(AppLocalizations.of(context).translate('select_sound_string')),
      content: Text(
          AppLocalizations.of(context).translate('select_sound_desc_string')),
      actions: [
        assetsButton,
        localButton,
        cancelButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog2(BuildContext context) {
    // set up the buttons
    Widget assetsButton = TextButton(
      child:
          Text(AppLocalizations.of(context).translate('default_sounds_string')),
      onPressed: () async {
        Navigator.of(context).pop();
        String _audioPath = await showDefaultSoundDialog(context);
        if (_audioPath != null) {
          setState(() {
            _currentAudioName2 = _audioPath;
            _settingsChanged = true;
          });
        }
      },
    );
    Widget localButton = TextButton(
      child: Text(AppLocalizations.of(context).translate('choose_string')),
      onPressed: () async {
        Navigator.of(context).pop();
        String _audioPath = await openAudioPicker();
        if (_audioPath != null) {
          setState(() {
            _currentAudioName2 = _audioPath;
            _settingsChanged = true;
          });
        }
      },
    );
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).translate('cancel_string')),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title:
          Text(AppLocalizations.of(context).translate('select_sound_string')),
      content: Text(
          AppLocalizations.of(context).translate('select_sound_desc_string')),
      actions: [
        assetsButton,
        localButton,
        cancelButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog3(BuildContext context) {
    // set up the buttons
    Widget assetsButton = TextButton(
      child:
          Text(AppLocalizations.of(context).translate('default_sounds_string')),
      onPressed: () async {
        Navigator.of(context).pop();
        String _audioPath = await showDefaultSoundDialog(context);
        if (_audioPath != null) {
          setState(() {
            _currentAudioName3 = _audioPath;
            _settingsChanged = true;
          });
        }
      },
    );
    Widget localButton = TextButton(
      child: Text(AppLocalizations.of(context).translate('choose_string')),
      onPressed: () async {
        Navigator.of(context).pop();
        String _audioPath = await openAudioPicker();
        if (_audioPath != null) {
          setState(() {
            _currentAudioName3 = _audioPath;
            _settingsChanged = true;
          });
        }
      },
    );
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).translate('cancel_string')),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title:
          Text(AppLocalizations.of(context).translate('select_sound_string')),
      content: Text(
          AppLocalizations.of(context).translate('select_sound_desc_string')),
      actions: [
        assetsButton,
        localButton,
        cancelButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Shows the default sounds to choose from assets folder
  showDefaultSoundDialog(BuildContext context) {
    Widget dfSound1 = ElevatedButton(
      onPressed: () => Navigator.pop(context, "audio/Bleep.mp3"),
      child: Text("Bleep"),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue[100],
        onPrimary: Colors.black,
      ),
    );
    Widget dfSound2 = ElevatedButton(
      onPressed: () => Navigator.pop(context, "audio/Censor-beep-3.mp3"),
      child: Text("Censor Beep 3"),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue[100],
        onPrimary: Colors.black,
      ),
    );
    Widget dfSound3 = ElevatedButton(
      onPressed: () => Navigator.pop(context, "audio/Foghorn.mp3"),
      child: Text("Foghorn"),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue[100],
        onPrimary: Colors.black,
      ),
    );
    Widget dfSound4 = ElevatedButton(
      onPressed: () => Navigator.pop(context, "audio/Grocery-Scanning.mp3"),
      child: Text("Grocery Scanning"),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue[100],
        onPrimary: Colors.black,
      ),
    );
    Widget dfSound5 = ElevatedButton(
      onPressed: () => Navigator.pop(context, "audio/Snort-1.mp3"),
      child: Text("Snort 1"),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue[100],
        onPrimary: Colors.black,
      ),
    );
    Widget dfSound6 = ElevatedButton(
      onPressed: () => Navigator.pop(context, "audio/Snort-2.mp3"),
      child: Text("Snort 2"),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue[100],
        onPrimary: Colors.black,
      ),
    );
    Widget dfSound7 = ElevatedButton(
      onPressed: () => Navigator.pop(context, "audio/Snort-3.mp3"),
      child: Text("Snort 3"),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue[100],
        onPrimary: Colors.black,
      ),
    );

    AlertDialog defaultSoundsDialog = AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            dfSound1,
            dfSound2,
            dfSound3,
            dfSound4,
            dfSound5,
            dfSound6,
            dfSound7
          ],
        ),
      ),
    );

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return defaultSoundsDialog;
        });
  }

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  Future<String> openAudioPicker() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    String path;
    if (result == null) {
      path = null;
    } else {
      path = result.files.single.path;
    }
    return path;
  }

  void saveSettingsValues(context) async {
    if (_currentAudioName1 == audioString) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.of(context).translate('snackbar_save_fail_string'),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.redAccent[400],
        duration: Duration(seconds: 2),
      ));
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("dbValue", _currentDbValue);
      prefs.setInt("persecValue", _currentPerSecValue);
      prefs.setString("persecUnit", _persecUnit);
      prefs.setInt("timesampleValue", _currentTimeSampleValue);
      prefs.setString("timesampleUnit", _timesampleUnit);
      prefs.setInt("timeoutValue", _currentTimeoutValue);
      prefs.setString("timeoutUnit", _timeoutUnit);
      prefs.setInt("audiovolumeValue", _currentAudioVolumeValue);
      prefs.setString("audioname1Value", _currentAudioName1);
      prefs.setBool("audioActive1", _audioActive1);
      prefs.setString("audioname2Value", _currentAudioName2);
      prefs.setBool("audioActive2", _audioActive2);
      prefs.setString("audioname3Value", _currentAudioName3);
      prefs.setBool("audioActive3", _audioActive3);
      prefs.setBool("algorithmValue", _algorithmValue);
      prefs.setBool("scheduleValue", _scheduleValue);
      prefs.setBool("hourlyValue", _hourlyValue);
      prefs.setBool("footageValue", _footageValue);
      _settingsChanged = false;
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.of(context)
              .translate('snackbar_save_success_string'),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.greenAccent[400],
        duration: Duration(seconds: 2),
      ));
    }
  }

  void saveSettingsValuesOnBackKey(context) async {
    if (_currentAudioName1 == audioString) {
      print("error!");
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("dbValue", _currentDbValue);
      prefs.setInt("persecValue", _currentPerSecValue);
      prefs.setString("persecUnit", _persecUnit);
      prefs.setInt("timesampleValue", _currentTimeSampleValue);
      prefs.setString("timesampleUnit", _timesampleUnit);
      prefs.setInt("timeoutValue", _currentTimeoutValue);
      prefs.setString("timeoutUnit", _timeoutUnit);
      prefs.setInt("audiovolumeValue", _currentAudioVolumeValue);
      prefs.setString("audioname1Value", _currentAudioName1);
      prefs.setString("audioname2Value", _currentAudioName2);
      prefs.setString("audioname3Value", _currentAudioName3);
      prefs.setBool("algorithmValue", _algorithmValue);
      prefs.setBool("scheduleValue", _scheduleValue);
      prefs.setBool("hourlyValue", _hourlyValue);
      prefs.setBool("footageValue", _footageValue);
      _settingsChanged = false;
    }
  }

  void resetSettingsValues() async {
    setState(() {
      _currentDbValue = 66;
      dbTresholdController.text = "66";
      _currentPerSecValue = 5;
      perSecController.text = "5";
      _persecUnit = "sec";
      _currentTimeSampleValue = 1;
      timeSampleController.text = "1";
      _timesampleUnit = "sec";
      _currentTimeoutValue = 6;
      timeoutController.text = "6";
      _timeoutUnit = "sec";
      _currentAudioName1 = "audio/Grocery-Scanning.mp3";
      _currentAudioName2 = "audio/Foghorn.mp3";
      _currentAudioName3 = "audio/Censor-beep-3.mp3";
      _currentAudioVolumeValue = 83;
      audioVolumeController.text = "83";
      _algorithmValue = false;
      _scheduleValue = false;
      _hourlyValue = false;
      _footageValue = false;
      _settingsChanged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onPop(context),
      child: Scaffold(
        backgroundColor: _bgColor,
        drawer: MyDrawer(),
        appBar: AppBar(
          title:
              Text(AppLocalizations.of(context).translate('settings_string')),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              soundVolume(context),
              dBTreshold(context),
              Visibility(
                child: Column(
                  children: [
                    perSec(context),
                    timeFrame(context),
                    timeout(context),
                  ],
                ),
                visible: _advancedSettings,
              ),
              Visibility(visible: _proVersion, child: setupschedule(context)),
              audio(context),
              Visibility(
                visible: _advancedSettings && _proVersion,
                child: Column(
                  children: [
                    setupHourlyStats(context),
                    setupFootageAudioGraphs(context),
                  ],
                ),
              ),
              Visibility(
                child: defaultSettings(context),
                visible: _advancedSettings,
              ),
              ButtonTheme(minWidth: 165, child: saveSettingsBuilder()),
              advancedSettings(context),
            ]),
          ),
        ),
      ),
    );
  }

  Future<bool> onPop(context) async {
    if (_settingsChanged) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)
                  .translate("save_dialog_back_key_string")),
              actions: [
                TextButton(
                  child:
                      Text(AppLocalizations.of(context).translate("no_string")),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, "/");
                    return false;
                  },
                ),
                TextButton(
                  child: Text(
                      AppLocalizations.of(context).translate("yes_string")),
                  onPressed: () {
                    Navigator.pop(context);
                    saveSettingsValuesOnBackKey(context);
                    Navigator.pushReplacementNamed(context, "/");
                    return false;
                  },
                )
              ],
            );
          });
    }
    Navigator.pushReplacementNamed(context, "/");
    return false;
  }

  GestureDetector setupschedule(BuildContext context) {
    return GestureDetector(
        onTap: (_proVersion)
            ? (() {})
            : (() {
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context).translate("pro_string"),
                    toastLength: Toast.LENGTH_SHORT);
              }),
        child:
            AbsorbPointer(absorbing: !_proVersion, child: schedule(context)));
  }

  GestureDetector setupAlgorithm(BuildContext context) {
    return GestureDetector(
        onTap: (_proVersion)
            ? (() {})
            : (() {
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context).translate("pro_string"),
                    toastLength: Toast.LENGTH_SHORT);
              }),
        child:
            AbsorbPointer(absorbing: !_proVersion, child: algorithm(context)));
  }

  GestureDetector setupHourlyStats(BuildContext context) {
    return GestureDetector(
        onTap: (_proVersion)
            ? (() {})
            : (() {
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context).translate("pro_string"),
                    toastLength: Toast.LENGTH_SHORT);
              }),
        child: AbsorbPointer(
            absorbing: !_proVersion, child: hourlyStats(context)));
  }

  GestureDetector setupFootageAudioGraphs(BuildContext context) {
    return GestureDetector(
        onTap: (_proVersion)
            ? (() {})
            : (() {
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context).translate("pro_string"),
                    toastLength: Toast.LENGTH_SHORT);
              }),
        child: AbsorbPointer(
            absorbing: !_proVersion, child: footageAudioGraphs(context)));
  }

  Container advancedSettings(BuildContext context) {
    return Container(
      child: ElevatedButtonTheme(
        data: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(
              Size(165, 37),
            ),
          ),
        ),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _advancedSettings = !_advancedSettings;
            });
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.blue[50],
            onPrimary: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _advancedSettings
              ? Text(
                  AppLocalizations.of(context)
                      .translate('advanced_settings_close_string'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : Text(
                  AppLocalizations.of(context)
                      .translate('advanced_settings_string'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  showAlertDialogOnSave(BuildContext context) {
    // set up the buttons
    Widget saveButton = TextButton(
      child: Text(AppLocalizations.of(context).translate('save_1_string')),
      onPressed: () {
        Navigator.of(context).pop(true);
        saveSettingsValues(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).translate('cancel_string')),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context).translate('save_string')),
      content: Text(
          AppLocalizations.of(context).translate('save_dialog_desc_string')),
      actions: [
        cancelButton,
        saveButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Builder saveSettingsBuilder() {
    return Builder(builder: (BuildContext context) {
      return ElevatedButtonTheme(
        data: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(
              Size(165, 37),
            ),
          ),
        ),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue[50],
              onPrimary: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => showAlertDialogOnSave(context),
            child: Text(
              AppLocalizations.of(context).translate('save_string'),
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
      );
    });
  }

  Container defaultSettings(BuildContext context) {
    return Container(
      child: ElevatedButtonTheme(
        data: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(
              Size(165, 37),
            ),
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue[50],
            onPrimary: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () => resetSettingsValues(),
          child: Text(
            AppLocalizations.of(context).translate('default_settings_string'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Container audio(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      decoration: sliderBoxDecoration(),
      child: Column(
        children: [
          Visibility(visible: _proVersion, child: setupAlgorithm(context)),
          Text(
            AppLocalizations.of(context).translate('audio_string'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          audioChooseControl1(),
          GestureDetector(
            onTap: (_proVersion)
                ? (() {})
                : (() {
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)
                            .translate("pro_string"),
                        toastLength: Toast.LENGTH_SHORT);
                  }),
            child: Column(
              children: [
                AbsorbPointer(
                  absorbing: (!_proVersion || !_algorithmValue),
                  child: Opacity(
                      opacity: (_proVersion && _algorithmValue) ? 1 : 0.3,
                      child: audioChooseControl2()),
                ),
                AbsorbPointer(
                  absorbing: (!_proVersion || !_algorithmValue),
                  child: Opacity(
                      opacity: (_proVersion && _algorithmValue) ? 1 : 0.3,
                      child: audioChooseControl3()),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container soundVolume(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      decoration: sliderBoxDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  AppLocalizations.of(context)
                          .translate('sound_volume_string') +
                      ":",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.only(left: 7.0),
                width: 40,
                child: TextField(
                  textAlign: TextAlign.end,
                  controller: audioVolumeController,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: '0',
                  ),
                  onChanged: (String text) {
                    if (double.parse(text) >= _audioVolumeMinValue &&
                        double.parse(text) <= _audioVolumeMaxValue) {
                      setState(() {
                        _currentAudioVolumeValue = int.parse(text);
                      });
                    }
                  },
                ),
              ),
              Container(
                  child: Text(
                "%",
                style: TextStyle(
                  fontSize: 18,
                ),
              )),
            ],
          ),
          audioVolumeSliderControl(_audioVolumeMinValue, _audioVolumeMaxValue),
        ],
      ),
    );
  }

  Container timeout(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      decoration: sliderBoxDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  AppLocalizations.of(context).translate('timeout_string') +
                      ":",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.only(left: 7.0, right: 5.0),
                width: 35,
                child: TextField(
                  textAlign: TextAlign.end,
                  controller: timeoutController,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: '0',
                  ),
                  onChanged: (String text) {
                    if (double.parse(text) >= _timeoutMinValue &&
                        double.parse(text) <= _timeoutMaxValue) {
                      setState(() {
                        _currentTimeoutValue = int.parse(text);
                      });
                    }
                  },
                ),
              ),
              Container(
                  width: 50,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _timeoutUnit,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.blueAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _timeoutUnit = newValue;
                        });
                      },
                      items: <String>['sec', 'min', 'hr']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  )),
            ],
          ),
          timeoutSliderControl(_timeoutMinValue, _timeoutMaxValue),
        ],
      ),
    );
  }

  Container timeFrame(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      decoration: sliderBoxDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  AppLocalizations.of(context).translate('time_frame_string') +
                      ":",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.only(left: 7.0, right: 5.0),
                width: 35,
                child: TextField(
                  textAlign: TextAlign.end,
                  controller: timeSampleController,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: '0',
                  ),
                  onChanged: (String text) {
                    if (double.parse(text) >= _timeSampleMinValue &&
                        double.parse(text) <= _timeSampleMaxValue) {
                      setState(() {
                        _currentTimeSampleValue = int.parse(text);
                      });
                    }
                  },
                ),
              ),
              Container(
                  width: 50,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _timesampleUnit,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.blueAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _timesampleUnit = newValue;
                        });
                      },
                      items: <String>['sec', 'min', 'hr']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  )),
            ],
          ),
          timeSampleSliderControl(_timeSampleMinValue, _timeSampleMaxValue),
        ],
      ),
    );
  }

  Container schedule(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      decoration: sliderBoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context).translate("schedule_string"),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 20,
          ),
          Switch(
            value: _scheduleValue,
            onChanged: (_proVersion) ? (val) => _setscheduleValue() : null,
          ),
        ],
      ),
    );
  }

  Container algorithm(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context).translate("algorithm_string"),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 20,
          ),
          Switch(
            value: _algorithmValue,
            onChanged: (_proVersion) ? (val) => _setAlgorithmValue() : null,
          ),
        ],
      ),
    );
  }

  Container hourlyStats(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      decoration: sliderBoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context).translate("hourly_string"),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 20,
          ),
          Switch(
            value: _hourlyValue,
            onChanged: (_proVersion) ? (val) => _setHourlyValue() : null,
          ),
        ],
      ),
    );
  }

  Container footageAudioGraphs(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      decoration: sliderBoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context).translate("footage_string"),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 20,
          ),
          Switch(
            value: _footageValue,
            onChanged: (_proVersion) ? (val) => _setFootageValue() : null,
          ),
        ],
      ),
    );
  }

  Container perSec(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      decoration: sliderBoxDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  AppLocalizations.of(context).translate('per_sec_string') +
                      ":",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.only(left: 7.0, right: 5.0),
                width: 35,
                child: TextField(
                  textAlign: TextAlign.end,
                  controller: perSecController,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: '0',
                  ),
                  onChanged: (String text) {
                    if (double.parse(text) >= _perSecMinValue &&
                        double.parse(text) <= _perSecMaxValue) {
                      setState(() {
                        _currentPerSecValue = int.parse(text);
                      });
                    }
                  },
                ),
              ),
              Container(
                  width: 50,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _persecUnit,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.blueAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _persecUnit = newValue;
                        });
                      },
                      items: <String>['sec', 'min', 'hr']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  )),
            ],
          ),
          perSecSliderControl(_perSecMinValue, _perSecMaxValue),
        ],
      ),
    );
  }

  Container dBTreshold(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      decoration: sliderBoxDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  AppLocalizations.of(context).translate('db_treshold_string') +
                      ":",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.only(left: 8.0),
                width: 35,
                child: TextField(
                  textAlign: TextAlign.end,
                  controller: dbTresholdController,
                  decoration: InputDecoration(
                    hintText: '0',
                    isCollapsed: true,
                  ),
                  onChanged: (String text) {
                    if (double.parse(text) >= _dbMinValue &&
                        double.parse(text) <= _dbMaxValue) {
                      setState(() {
                        _currentDbValue = int.parse(text);
                      });
                    }
                  },
                ),
              ),
              Container(
                  child: Text(
                "dB",
                style: TextStyle(
                  fontSize: 18,
                ),
              ))
            ],
          ),
          dBTresholdSliderControl(_dbMinValue, _dbMaxValue),
        ],
      ),
    );
  }

  BoxDecoration sliderBoxDecoration() {
    return BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          )
        ]);
  }

  Timer assetPlayingTimer;
//Play audio file
  void playAudio(String audioFile) async {
    assetPlayingTimer?.cancel();
    await audioPlayer?.stop();
    await audioPlayer?.release();
    if (_defaultSounds.containsKey(audioFile)) {
      audioPlayer = await assetPlayer.play(audioFile);
      assetPlayingTimer =
          Timer(Duration(seconds: _defaultSounds[audioFile]), () {
        setState(() {
          _audio1Playing = false;
          _audio2Playing = false;
          _audio3Playing = false;
        });
      });
    } else {
      await audioPlayer.play(audioFile, isLocal: true);
    }
  }

  //Stops audio file
  void stopAudio() async {
    assetPlayingTimer?.cancel();
    await audioPlayer?.stop();
    await audioPlayer?.release();
  }

  // Widget for audio chooser 1
  Row audioChooseControl1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: AbsorbPointer(
            absorbing: !_audioActive1,
            child: Opacity(
              opacity: (_audioActive1) ? 1 : 0.3,
              child: GestureDetector(
                onTap: () => showAlertDialog1(context),
                child: Text((_currentAudioName1 != audioString &&
                        _currentAudioName1 != null)
                    ? (_currentAudioName1
                        .split("/")[_currentAudioName1.split("/").length - 1])
                    : AppLocalizations.of(context)
                        .translate('choose_sound_string')),
              ),
            ),
          ),
        ),
        (_audioActive1)
            ? IconButton(
                icon: Icon((!_audio1Playing) ? Icons.play_arrow : Icons.stop),
                color: Colors.blue,
                onPressed: () {
                  (_audio1Playing)
                      ? stopAudio()
                      : playAudio(_currentAudioName1);
                  setState(() {
                    _audio1Playing = !_audio1Playing;
                    _audio2Playing = false;
                    _audio3Playing = false;
                  });
                  audioPlayer.onPlayerCompletion.listen((event) {
                    print("HAHA");
                    setState(() {
                      _audio1Playing = false;
                    });
                  });
                },
              )
            : Text(""),
        Checkbox(
          value: _audioActive1,
          onChanged: _setActiveAudio1,
        ),
      ],
    );
  }

  void _setActiveAudio1(bool val) {
    if (_audioActive2 || _audioActive3) {
      setState(() {
        _audioActive1 = val;
        _settingsChanged = true;
      });
    }
  }

// Widget for audio chooser 2
  Row audioChooseControl2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: AbsorbPointer(
            absorbing: !_audioActive2,
            child: Opacity(
              opacity: (_audioActive2) ? 1 : 0.3,
              child: GestureDetector(
                onTap: () => showAlertDialog2(context),
                child: Text((_currentAudioName2 != audioString &&
                        _currentAudioName2 != null)
                    ? (_currentAudioName2
                        .split("/")[_currentAudioName2.split("/").length - 1])
                    : AppLocalizations.of(context)
                        .translate('choose_sound_string')),
              ),
            ),
          ),
        ),
        (_audioActive2)
            ? IconButton(
                icon: Icon((!_audio2Playing) ? Icons.play_arrow : Icons.stop),
                color: Colors.blue,
                onPressed: () {
                  (_audio2Playing)
                      ? stopAudio()
                      : playAudio(_currentAudioName2);
                  setState(() {
                    _audio2Playing = !_audio2Playing;
                    _audio1Playing = false;
                    _audio3Playing = false;
                  });
                  audioPlayer.onPlayerCompletion.listen((event) {
                    setState(() {
                      _audio2Playing = false;
                    });
                  });
                },
              )
            : Text(""),
        Checkbox(
          value: _audioActive2,
          onChanged: _setActiveAudio2,
        ),
      ],
    );
  }

  void _setActiveAudio2(bool val) {
    if (_audioActive1 || _audioActive3) {
      setState(() {
        _audioActive2 = val;
        _settingsChanged = true;
      });
    }
  }

  // Widget for audio chooser 3
  Row audioChooseControl3() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: AbsorbPointer(
            absorbing: !_audioActive3,
            child: Opacity(
              opacity: (_audioActive3) ? 1 : 0.3,
              child: GestureDetector(
                  onTap: () => showAlertDialog3(context),
                  child: Text((_currentAudioName3 != audioString &&
                          _currentAudioName3 != null)
                      ? (_currentAudioName3
                          .split("/")[_currentAudioName3.split("/").length - 1])
                      : AppLocalizations.of(context)
                          .translate('choose_sound_string'))),
            ),
          ),
        ),
        (_audioActive3)
            ? IconButton(
                icon: Icon((!_audio3Playing) ? Icons.play_arrow : Icons.stop),
                color: Colors.blue,
                onPressed: () {
                  (_audio3Playing)
                      ? stopAudio()
                      : playAudio(_currentAudioName3);
                  setState(() {
                    _audio3Playing = !_audio3Playing;
                    _audio1Playing = false;
                    _audio2Playing = false;
                  });
                  audioPlayer.onPlayerCompletion.listen((event) {
                    setState(() {
                      _audio3Playing = false;
                    });
                  });
                },
              )
            : Text(""),
        Checkbox(
          value: _audioActive3,
          onChanged: _setActiveAudio3,
        ),
      ],
    );
  }

  void _setActiveAudio3(bool val) {
    if (_audioActive1 || _audioActive2) {
      setState(() {
        _audioActive3 = val;
        _settingsChanged = true;
      });
    }
  }

  // Widget for dB slider
  Row dBTresholdSliderControl(double minVal, double maxVal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            if (_currentDbValue > minVal) {
              setState(() {
                _currentDbValue--;
                dbTresholdController.text = _currentDbValue.toString();
              });
            }
          },
          child: Icon(Icons.remove),
        ),
        Flexible(
          child: Slider(
              min: minVal,
              max: maxVal,
              divisions: (maxVal - minVal).round(),
              value: _currentDbValue?.toDouble() ?? 66,
              label: _currentDbValue?.toString() ?? '66',
              onChanged: (double val) {
                setState(() {
                  _currentDbValue = val.round();
                  dbTresholdController.text = val.round().toString();
                });
              }),
        ),
        GestureDetector(
          onTap: () {
            if (_currentDbValue < maxVal) {
              setState(() {
                _currentDbValue++;
                dbTresholdController.text = _currentDbValue.toString();
              });
            }
          },
          child: Icon(Icons.add),
        ),
      ],
    );
  }

  // Widget for persec slider
  Row perSecSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_currentPerSecValue > minVal) {
              setState(() {
                _currentPerSecValue--;
                perSecController.text = _currentPerSecValue.toString();
              });
            }
          },
          child: Icon(Icons.remove),
        ),
        Flexible(
          child: Slider(
              min: minVal,
              max: maxVal,
              divisions: (maxVal - minVal).round(),
              value: _currentPerSecValue?.toDouble() ?? 5,
              label: _currentPerSecValue?.toString() ?? '5',
              onChanged: (double val) {
                setState(() {
                  _currentPerSecValue = val.round();
                  perSecController.text = val.round().toString();
                });
              }),
        ),
        GestureDetector(
          onTap: () {
            if (_currentPerSecValue < maxVal) {
              setState(() {
                _currentPerSecValue++;
                perSecController.text = _currentPerSecValue.toString();
              });
            }
          },
          child: Icon(Icons.add),
        ),
      ],
    );
  }

  // Widget for time frame slider
  Row timeSampleSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_currentTimeSampleValue > minVal) {
              setState(() {
                _currentTimeSampleValue--;
                timeSampleController.text = _currentTimeSampleValue.toString();
              });
            }
          },
          child: Icon(Icons.remove),
        ),
        Flexible(
          child: Slider(
              min: minVal,
              max: maxVal,
              divisions: (maxVal - minVal).round(),
              value: _currentTimeSampleValue?.toDouble() ?? 1,
              label: _currentTimeSampleValue?.toString() ?? '1',
              onChanged: (double val) {
                setState(() {
                  _currentTimeSampleValue = val.round();
                  timeSampleController.text = val.round().toString();
                });
              }),
        ),
        GestureDetector(
          onTap: () {
            if (_currentTimeSampleValue < maxVal) {
              setState(() {
                _currentTimeSampleValue++;
                timeSampleController.text = _currentTimeSampleValue.toString();
              });
            }
          },
          child: Icon(Icons.add),
        ),
      ],
    );
  }

  // widget for timeout slider
  Row timeoutSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_currentTimeoutValue > minVal) {
              setState(() {
                _currentTimeoutValue--;
                timeoutController.text = _currentTimeoutValue.toString();
              });
            }
          },
          child: Icon(Icons.remove),
        ),
        Flexible(
          child: Slider(
              min: minVal,
              max: maxVal,
              divisions: (maxVal - minVal).round(),
              value: _currentTimeoutValue?.toDouble() ?? 6,
              label: _currentTimeoutValue?.toString() ?? '6',
              onChanged: (double val) {
                setState(() {
                  _currentTimeoutValue = val.round();
                  timeoutController.text = val.round().toString();
                });
              }),
        ),
        GestureDetector(
          onTap: () {
            if (_currentTimeoutValue < maxVal) {
              setState(() {
                _currentTimeoutValue++;
                timeoutController.text = _currentTimeoutValue.toString();
              });
            }
          },
          child: Icon(Icons.add),
        ),
      ],
    );
  }

  Row audioVolumeSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_currentAudioVolumeValue > minVal) {
              setState(() {
                _currentAudioVolumeValue--;
                audioVolumeController.text =
                    _currentAudioVolumeValue.toString();
              });
            }
          },
          child: Icon(Icons.remove),
        ),
        Flexible(
          child: Slider(
              min: minVal,
              max: maxVal,
              divisions: (maxVal - minVal).round(),
              value: _currentAudioVolumeValue?.toDouble() ?? 70,
              label: _currentAudioVolumeValue?.toString() ?? '70',
              onChanged: (double val) {
                setState(() {
                  _currentAudioVolumeValue = val.round();
                  audioVolumeController.text = val.round().toString();
                });
              }),
        ),
        GestureDetector(
          onTap: () {
            if (_currentAudioVolumeValue < maxVal) {
              setState(() {
                _currentAudioVolumeValue++;
                audioVolumeController.text =
                    _currentAudioVolumeValue.toString();
              });
            }
          },
          child: Icon(Icons.add),
        ),
      ],
    );
  }
}

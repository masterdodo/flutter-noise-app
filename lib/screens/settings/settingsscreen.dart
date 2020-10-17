import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:noise_app/components/my_drawer.dart';
import 'package:noise_app/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final snackBarSuccessSettings = SnackBar(
    content: Text(
      "Settings saved successfully!",
      style: TextStyle(color: Colors.black),
    ),
    backgroundColor: Colors.greenAccent[400],
    duration: Duration(seconds: 2),
  );

  final snackBarFailSettings = SnackBar(
    content: Text(
      "Settings not saved! You have to choose a sound.",
      style: TextStyle(color: Colors.black),
    ),
    backgroundColor: Colors.redAccent[400],
    duration: Duration(seconds: 2),
  );

  final audioString = "Choose audio file...";

  Timer timer; //timer used for persec dB checks

  Color _bgColor = Colors.white; //default bg color of app
  // _current - realtime values of sliders, active - values after recoding started
  int _currentDbValue,
      _currentPerSecValue,
      _currentTimeSampleValue,
      _currentAudioVolumeValue,
      _currentTimeoutValue;

  bool _advancedSettings = false;

  String _persecUnit = "sec";
  String _timesampleUnit = "sec";
  String _timeoutUnit = "sec";

  String _currentAudioName1; //current audio name
  String _currentAudioName2; //current audio name
  String _currentAudioName3; //current audio name

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentDbValue = prefs.getInt("dbValue") ?? 30;
      _currentPerSecValue = prefs.getInt("persecValue") ?? 1;
      _currentTimeSampleValue = prefs.getInt("timesampleValue") ?? 1;
      _currentTimeoutValue = prefs.getInt("timeoutValue") ?? 1;
      _currentAudioVolumeValue = prefs.getInt("audiovolumeValue") ?? 100;
      _currentAudioName1 = prefs.getString("audioname1Value") ?? audioString;
      _currentAudioName2 = prefs.getString("audioname2Value") ?? audioString;
      _currentAudioName3 = prefs.getString("audioname3Value") ?? audioString;
      _persecUnit = prefs.getString("persecUnit") ?? 'sec';
      _timesampleUnit = prefs.getString("timesampleUnit") ?? 'sec';
      _timeoutUnit = prefs.getString("timeoutUnit") ?? 'sec';
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  showAlertDialog1(BuildContext context) {
    // set up the buttons
    Widget assetsButton = FlatButton(
      child: Text("Default Sounds"),
      onPressed: () {
        Navigator.of(context).pop();
        showDefaultSoundDialog1(context);
      },
    );
    Widget localButton = FlatButton(
      child: Text("Choose..."),
      onPressed: () {
        Navigator.of(context).pop();
        openAudioPicker1();
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Select a Sound"),
      content: Text(
          "Choose 'Default Sounds' for preset alerts or 'Choose...' if you want to use your own sound."),
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

  showDefaultSoundDialog1(BuildContext context) {
    Widget dfSound1 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName1 = "audio/Bleep.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Bleep"),
      color: Colors.blue[100],
    );
    Widget dfSound2 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName1 = "audio/Censor-beep-3.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Censor Beep 3"),
      color: Colors.blue[100],
    );
    Widget dfSound3 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName1 = "audio/Foghorn.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Foghorn"),
      color: Colors.blue[100],
    );
    Widget dfSound4 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName1 = "audio/Grocery-Scanning.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Grocery Scanning"),
      color: Colors.blue[100],
    );

    AlertDialog defaultSoundsDialog = AlertDialog(
      content: SizedBox(
        height: 200,
        child: ListView(
          children: [dfSound1, dfSound2, dfSound3, dfSound4],
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return defaultSoundsDialog;
        });
  }

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  void openAudioPicker1() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    String path;
    if (result == null) {
      path = _currentAudioName1;
    } else {
      path = result.files.single.path;
    }
    setState(() {
      _currentAudioName1 = path;
    });
  }

  void removeAudio1() {
    setState(() {
      _currentAudioName1 = audioString;
    });
  }

  showAlertDialog2(BuildContext context) {
    // set up the buttons
    Widget assetsButton = FlatButton(
      child: Text("Default Sounds"),
      onPressed: () {
        Navigator.of(context).pop();
        showDefaultSoundDialog2(context);
      },
    );
    Widget localButton = FlatButton(
      child: Text("Choose..."),
      onPressed: () {
        Navigator.of(context).pop();
        openAudioPicker2();
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Select a Sound"),
      content: Text(
          "Choose 'Default Sounds' for preset alerts or 'Choose...' if you want to use your own sound."),
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

  showDefaultSoundDialog2(BuildContext context) {
    Widget dfSound1 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName2 = "audio/Bleep.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Bleep"),
      color: Colors.blue[100],
    );
    Widget dfSound2 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName2 = "audio/Censor-beep-3.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Censor Beep 3"),
      color: Colors.blue[100],
    );
    Widget dfSound3 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName2 = "audio/Foghorn.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Foghorn"),
      color: Colors.blue[100],
    );
    Widget dfSound4 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName2 = "audio/Grocery-Scanning.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Grocery Scanning"),
      color: Colors.blue[100],
    );

    AlertDialog defaultSoundsDialog = AlertDialog(
      content: SizedBox(
        height: 200,
        child: ListView(
          children: [dfSound1, dfSound2, dfSound3, dfSound4],
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return defaultSoundsDialog;
        });
  }

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  void openAudioPicker2() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    String path;
    if (result == null) {
      path = _currentAudioName2;
    } else {
      path = result.files.single.path;
    }
    setState(() {
      _currentAudioName2 = path;
    });
  }

  void removeAudio2() {
    setState(() {
      _currentAudioName2 = audioString;
    });
  }

  showAlertDialog3(BuildContext context) {
    // set up the buttons
    Widget assetsButton = FlatButton(
      child: Text("Default Sounds"),
      onPressed: () {
        Navigator.of(context).pop();
        showDefaultSoundDialog3(context);
      },
    );
    Widget localButton = FlatButton(
      child: Text("Choose..."),
      onPressed: () {
        Navigator.of(context).pop();
        openAudioPicker3();
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Select a Sound"),
      content: Text(
          "Choose 'Default Sounds' for preset alerts or 'Choose...' if you want to use your own sound."),
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

  showDefaultSoundDialog3(BuildContext context) {
    Widget dfSound1 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName3 = "audio/Bleep.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Bleep"),
      color: Colors.blue[100],
    );
    Widget dfSound2 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName3 = "audio/Censor-beep-3.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Censor Beep 3"),
      color: Colors.blue[100],
    );
    Widget dfSound3 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName3 = "audio/Foghorn.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Foghorn"),
      color: Colors.blue[100],
    );
    Widget dfSound4 = RaisedButton(
      onPressed: () {
        setState(() {
          _currentAudioName3 = "audio/Grocery-Scanning.mp3";
        });
        Navigator.of(context).pop();
      },
      child: Text("Grocery Scanning"),
      color: Colors.blue[100],
    );

    AlertDialog defaultSoundsDialog = AlertDialog(
      content: SizedBox(
        height: 200,
        child: ListView(
          children: [dfSound1, dfSound2, dfSound3, dfSound4],
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return defaultSoundsDialog;
        });
  }

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  void openAudioPicker3() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    String path;
    if (result == null) {
      path = _currentAudioName3;
    } else {
      path = result.files.single.path;
    }
    setState(() {
      _currentAudioName3 = path;
    });
  }

  void removeAudio3() {
    setState(() {
      _currentAudioName3 = audioString;
    });
  }

  void saveSettingsValues(context) async {
    if (_currentAudioName1 == audioString) {
      Scaffold.of(context).showSnackBar(snackBarFailSettings);
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
      Scaffold.of(context).showSnackBar(snackBarSuccessSettings);
    }
  }

  void resetSettingsValues() async {
    setState(() {
      _currentDbValue = 66;
      _currentPerSecValue = 5;
      _persecUnit = "sec";
      _currentTimeSampleValue = 1;
      _timesampleUnit = "sec";
      _currentTimeoutValue = 6;
      _timeoutUnit = "sec";
      _currentAudioName1 = "audio/Grocery-Scanning.mp3";
      _currentAudioName2 = "audio/Foghorn.mp3";
      _currentAudioName3 = "audio/Censor-beep-3.mp3";
      _currentAudioVolumeValue = 70;
    });
    /*SharedPreferences prefs = await SharedPreferences.getInstance();
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
    prefs.setString("audioname3Value", _currentAudioName3);*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings_string')),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
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
            soundVolume(context),
            audio(context),
            Visibility(
              child: defaultSettings(context),
              visible: _advancedSettings,
            ),
            saveSettingsBuilder(),
            Visibility(
              child: advancedSettings(context),
              visible: !_advancedSettings,
            ),
          ]),
        ),
      ),
    );
  }

  Container advancedSettings(BuildContext context) {
    return Container(
      child: RaisedButton(
        onPressed: () {
          setState(() {
            _advancedSettings = !_advancedSettings;
          });
        },
        color: Colors.blue[50],
        padding: EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: _advancedSettings
            ? Text(
                AppLocalizations.of(context).translate('close_string'),
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                AppLocalizations.of(context)
                    .translate('advanced_settings_string'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  showAlertDialogOnSave(BuildContext context) {
    // set up the buttons
    Widget saveButton = FlatButton(
      child: Text("Save"),
      onPressed: () {
        Navigator.of(context).pop();
        saveSettingsValues(context);
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Saving"),
      content: Text("Are you sure you want to save this settings?"),
      actions: [
        saveButton,
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

  Builder saveSettingsBuilder() {
    return Builder(builder: (BuildContext context) {
      return RaisedButton(
          color: Colors.greenAccent[100],
          padding: EdgeInsets.symmetric(horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: () => showAlertDialogOnSave(context),
          child: Text(
            AppLocalizations.of(context).translate('save_string'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ));
    });
  }

  Container defaultSettings(BuildContext context) {
    return Container(
      child: RaisedButton(
        onPressed: () => resetSettingsValues(),
        color: Colors.blue[50],
        padding: EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(
          AppLocalizations.of(context).translate('default_settings_string'),
          style: TextStyle(fontWeight: FontWeight.bold),
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
          Text(
            AppLocalizations.of(context).translate('audio_string'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          audioChooseControl1(),
          AbsorbPointer(
            absorbing: !(_currentAudioName1 != audioString),
            child: Opacity(
                opacity: (_currentAudioName1 != audioString) ? 1 : 0.3,
                child: audioChooseControl2()),
          ),
          AbsorbPointer(
            absorbing: !(_currentAudioName1 != audioString &&
                _currentAudioName2 != audioString),
            child: Opacity(
                opacity: (_currentAudioName1 != audioString &&
                        _currentAudioName2 != audioString)
                    ? 1
                    : 0.3,
                child: audioChooseControl3()),
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
          Text(AppLocalizations.of(context).translate('sound_volume_string'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          audioVolumeSliderControl(1, 100),
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
          Text(AppLocalizations.of(context).translate('timeout_string'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          timeoutSliderControl(1, 60),
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
          Text(AppLocalizations.of(context).translate('time_frame_string'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          timeSampleSliderControl(1, 60),
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
          Text(AppLocalizations.of(context).translate('per_sec_string'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          perSecSliderControl(1, 60),
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
          Text(AppLocalizations.of(context).translate('db_treshold_string'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          dBTresholdSliderControl(30, 150),
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

  // Widget for audio chooser 1
  Row audioChooseControl1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 40,
          height: 50,
          child: IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () => showAlertDialog1(context),
          ),
        ),
        Flexible(
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
        Container(
          width: 40,
          height: 50,
          child: Text(""),
        )
      ],
    );
  }

// Widget for audio chooser 2
  Row audioChooseControl2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 40,
          height: 50,
          child: IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () => showAlertDialog2(context),
          ),
        ),
        Flexible(
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
        Container(
          width: 40,
          height: 50,
          child: IconButton(
            icon: Icon(
              Icons.delete,
              color: (_currentAudioName3 == audioString &&
                      _currentAudioName2 != audioString)
                  ? Colors.red
                  : Colors.grey,
            ),
            onPressed: (_currentAudioName3 == audioString &&
                    _currentAudioName2 != audioString)
                ? () => removeAudio2()
                : null,
          ),
        )
      ],
    );
  }

  // Widget for audio chooser 3
  Row audioChooseControl3() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 40,
          height: 50,
          child: IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () => showAlertDialog3(context),
          ),
        ),
        Flexible(
          child: GestureDetector(
              onTap: () => showAlertDialog3(context),
              child: Text((_currentAudioName3 != audioString &&
                      _currentAudioName3 != null)
                  ? (_currentAudioName3
                      .split("/")[_currentAudioName3.split("/").length - 1])
                  : AppLocalizations.of(context)
                      .translate('choose_sound_string'))),
        ),
        Container(
          width: 40,
          height: 50,
          child: IconButton(
            icon: Icon(
              Icons.delete,
              color: (_currentAudioName3 != audioString)
                  ? Colors.red
                  : Colors.grey,
            ),
            onPressed: (_currentAudioName3 != audioString)
                ? () => removeAudio3()
                : null,
          ),
        )
      ],
    );
  }

  // Widget for dB slider
  Row dBTresholdSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
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
                });
              }),
        ),
        Container(
          width: 30,
          child: TextField(
            controller: TextEditingController(text: _currentDbValue.toString()),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '0'),
            onChanged: (String text) {
              if (double.parse(text) >= minVal &&
                  double.parse(text) <= maxVal) {
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
    );
  }

  // Widget for persec slider
  Row perSecSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
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
                });
              }),
        ),
        Container(
          width: 30,
          child: TextField(
            controller:
                TextEditingController(text: _currentPerSecValue.toString()),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '0'),
            onChanged: (String text) {
              if (double.parse(text) >= minVal &&
                  double.parse(text) <= maxVal) {
                setState(() {
                  _currentPerSecValue = int.parse(text);
                });
              }
            },
          ),
        ),
        Container(
            width: 46,
            child: DropdownButton<String>(
              value: _persecUnit,
              icon: Icon(Icons.arrow_downward),
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
            )),
      ],
    );
  }

  // Widget for time frame slider
  Row timeSampleSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
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
                });
              }),
        ),
        Container(
          width: 30,
          child: TextField(
            controller:
                TextEditingController(text: _currentTimeSampleValue.toString()),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '0'),
            onChanged: (String text) {
              if (double.parse(text) >= minVal &&
                  double.parse(text) <= maxVal) {
                setState(() {
                  _currentTimeSampleValue = int.parse(text);
                });
              }
            },
          ),
        ),
        Container(
            width: 46,
            child: DropdownButton<String>(
              value: _timesampleUnit,
              icon: Icon(Icons.arrow_downward),
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
            )),
      ],
    );
  }

  // widget for timeout slider
  Row timeoutSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
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
                });
              }),
        ),
        Container(
          width: 30,
          child: TextField(
            controller:
                TextEditingController(text: _currentTimeoutValue.toString()),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '0'),
            onChanged: (String text) {
              if (double.parse(text) >= minVal &&
                  double.parse(text) <= maxVal) {
                setState(() {
                  _currentTimeoutValue = int.parse(text);
                });
              }
            },
          ),
        ),
        Container(
            width: 46,
            child: DropdownButton<String>(
              value: _timeoutUnit,
              icon: Icon(Icons.arrow_downward),
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
            )),
      ],
    );
  }

  Row audioVolumeSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
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
                });
              }),
        ),
        Container(
          width: 30,
          child: TextField(
            controller: TextEditingController(
                text: _currentAudioVolumeValue.toString()),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '0'),
            onChanged: (String text) {
              if (double.parse(text) >= minVal &&
                  double.parse(text) <= maxVal) {
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
    );
  }
}

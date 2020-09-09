import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
      _currentTimeoutValue = 0;

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

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  void openAudioPicker1() async {
    String path = await FilePicker.getFilePath(type: FileType.audio) ??
        _currentAudioName1;
    setState(() {
      _currentAudioName1 = path;
    });
  }

  void removeAudio1() {
    setState(() {
      _currentAudioName1 = audioString;
    });
  }

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  void openAudioPicker2() async {
    String path = await FilePicker.getFilePath(type: FileType.audio) ??
        _currentAudioName2;
    setState(() {
      _currentAudioName2 = path;
    });
  }

  void removeAudio2() {
    setState(() {
      _currentAudioName2 = audioString;
    });
  }

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  void openAudioPicker3() async {
    String path = await FilePicker.getFilePath(type: FileType.audio) ??
        _currentAudioName3;
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
      prefs.setString("audioname1Value", _currentAudioName1);
      prefs.setString("audioname2Value", _currentAudioName2);
      prefs.setString("audioname3Value", _currentAudioName3);
      Scaffold.of(context).showSnackBar(snackBarSuccessSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings_string')),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.all(5),
              decoration: sliderBoxDecoration(),
              child: Column(
                children: [
                  Text(
                      AppLocalizations.of(context)
                          .translate('db_treshold_string'),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  dBTresholdSliderControl(30, 150),
                ],
              ),
            ),
            Container(
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
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.all(5),
              decoration: sliderBoxDecoration(),
              child: Column(
                children: [
                  Text(
                      AppLocalizations.of(context)
                          .translate('time_frame_string'),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  timeSampleSliderControl(1, 60),
                ],
              ),
            ),
            Container(
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
            ),
            Container(
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
            ),
            Builder(builder: (BuildContext context) {
              return RaisedButton(
                  color: Colors.greenAccent[100],
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  onPressed: () => saveSettingsValues(context),
                  child: Text(
                    AppLocalizations.of(context).translate('save_string'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ));
            })
          ]),
        ),
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
      children: [
        Container(
          width: 40,
          height: 50,
          child: IconButton(
            icon: Icon(
              Icons.delete,
              color: (_currentAudioName3 == audioString &&
                      _currentAudioName2 == audioString &&
                      _currentAudioName1 != audioString)
                  ? Colors.red
                  : Colors.grey,
            ),
            onPressed: (_currentAudioName3 == audioString &&
                    _currentAudioName2 == audioString &&
                    _currentAudioName1 != audioString)
                ? () => removeAudio1()
                : null,
          ),
        ),
        Container(
          width: 40,
          height: 50,
          child: IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () => openAudioPicker1(),
          ),
        ),
        Flexible(
          child: GestureDetector(
              onTap: () => openAudioPicker1(),
              child: Text(_currentAudioName1
                  .split("/")[_currentAudioName1.split("/").length - 1])),
        ),
      ],
    );
  }

// Widget for audio chooser 2
  Row audioChooseControl2() {
    return Row(
      children: [
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
        ),
        Container(
          width: 40,
          height: 50,
          child: IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () => openAudioPicker2(),
          ),
        ),
        Flexible(
          child: GestureDetector(
              onTap: () => openAudioPicker2(),
              child: Text(_currentAudioName2
                  .split("/")[_currentAudioName2.split("/").length - 1])),
        ),
      ],
    );
  }

  // Widget for audio chooser 3
  Row audioChooseControl3() {
    return Row(
      children: [
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
        ),
        Container(
          width: 40,
          height: 50,
          child: IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () => openAudioPicker3(),
          ),
        ),
        Flexible(
          child: GestureDetector(
              onTap: () => openAudioPicker3(),
              child: Text(_currentAudioName3
                  .split("/")[_currentAudioName3.split("/").length - 1])),
        ),
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
              value: _currentDbValue.toDouble(),
              label: _currentDbValue.toString(),
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
                InputDecoration(border: InputBorder.none, hintText: 'dB'),
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
              value: _currentPerSecValue.toDouble(),
              label: _currentPerSecValue.toString(),
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
                InputDecoration(border: InputBorder.none, hintText: 'dB'),
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
              value: _currentTimeSampleValue.toDouble(),
              label: _currentTimeSampleValue.toString(),
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
                InputDecoration(border: InputBorder.none, hintText: 'dB'),
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
              value: _currentTimeoutValue.toDouble(),
              label: _currentTimeoutValue.toString(),
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
                InputDecoration(border: InputBorder.none, hintText: 'dB'),
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
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final snackBar = SnackBar(
    content: Text(
      "Settings saved successfully!",
      style: TextStyle(color: Colors.black),
    ),
    backgroundColor: Colors.greenAccent[400],
    duration: Duration(seconds: 2),
  );

  Timer timer; //timer used for persec dB checks

  Color _bgColor = Colors.white; //default bg color of app
  // _current - realtime values of sliders, active - values after recoding started
  int _currentDbValue,
      _currentPerSecValue,
      _currentTimeSampleValue,
      _currentTimeoutValue = 0;

  String _currentAudioName1 = "Choose audio file..."; //current audio name
  String _currentAudioName2 = "Choose audio file..."; //current audio name
  String _currentAudioName3 = "Choose audio file..."; //current audio name

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentDbValue = prefs.getInt("dbValue") ?? 30;
      _currentPerSecValue = prefs.getInt("persecValue") ?? 1;
      _currentTimeSampleValue = prefs.getInt("timesampleValue") ?? 1;
      _currentTimeoutValue = prefs.getInt("timeoutValue") ?? 1;
      _currentAudioName1 = prefs.getString("audioname1Value") ?? '0';
      _currentAudioName2 = prefs.getString("audioname2Value") ?? '0';
      _currentAudioName3 = prefs.getString("audioname3Value") ?? '0';
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
    String path = await FilePicker.getFilePath(type: FileType.audio);
    setState(() {
      _currentAudioName1 = path;
    });
  }

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  void openAudioPicker2() async {
    String path = await FilePicker.getFilePath(type: FileType.audio);
    setState(() {
      _currentAudioName2 = path;
    });
  }

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  void openAudioPicker3() async {
    String path = await FilePicker.getFilePath(type: FileType.audio);
    setState(() {
      _currentAudioName3 = path;
    });
  }

  void saveSettingsValues(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("dbValue", _currentDbValue);
    prefs.setInt("persecValue", _currentPerSecValue);
    prefs.setInt("timesampleValue", _currentTimeSampleValue);
    prefs.setInt("timeoutValue", _currentTimeoutValue);
    prefs.setString("audioname1Value", _currentAudioName1);
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.orange[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Text("dB Treshold"),
          dBTresholdSliderControl(30, 150),
          Text("Check For Value Per Second"),
          perSecSliderControl(1, 100),
          Text("Time Frame To Check Treshold"),
          timeSampleSliderControl(1, 600),
          Text("Timeout after alert"),
          timeoutSliderControl(1, 100),
          Text("Audio Alert On Treshold"),
          audioChooseControl(),
          Builder(builder: (BuildContext context) {
            return FlatButton(
                onPressed: () => saveSettingsValues(context),
                child: Text("Save Settings"));
          })
        ]),
      ),
    );
  }

  // Widget for audio chooser
  Row audioChooseControl() {
    return Row(
      children: [
        Container(
          width: 50,
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
      ],
    );
  }

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
      ],
    );
  }
}

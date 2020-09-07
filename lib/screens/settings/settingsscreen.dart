import 'package:noise_meter/noise_meter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isRecording; //mic button recording on or off
  StreamSubscription<NoiseReading>
      _noiseSubscription; //getting dB values from mic
  NoiseMeter _noiseMeter; //getting dB values from mic
  AudioPlayer audioPlayer; //audio alert player

  final controller = TextEditingController(); //text controller
  Timer timer; //timer used for persec dB checks

  Color _bgColor = Colors.white; //default bg color of app
  // absolute path of current audio file, selected audio file after recording started
  String absAudioPath, activeAudioFile;
  // _current - realtime values of sliders, active - values after recoding started
  double _currentDbValue,
      _currentPerSecValue,
      _currentTimeSampleValue,
      activeDbValue,
      activePerSecValue,
      activeTimeSampleValue;

  String _currentAudioName1 =
      "Choose audio file..."; //current audio name(without path)

  String _dBValueRealTime; //realtime dB value when recording

  List<double> dBValueList; //array of realtime values for chosen time frame
  int arrLength; //length of array based on time frame and persec value

  TextEditingController _controllerDbValue;
  TextEditingController _controllerPersecValue;
  TextEditingController _controllerTimesampleValue;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentDbValue = prefs.getDouble("dbValue");
    _currentPerSecValue = prefs.getDouble("persecValue");
    _currentTimeSampleValue = prefs.getDouble("timesampleValue");
    _currentAudioName1 = prefs.getString("audioname1Value");
  }

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _noiseMeter = new NoiseMeter();
    _isRecording = false;
    _currentDbValue = 70;
    _currentPerSecValue = 1;
    _currentTimeSampleValue = 60;
    arrLength = 0;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  void openAudioPicker() async {
    String path = await FilePicker.getFilePath(type: FileType.audio);
    setState(() {
      absAudioPath = path;
      _currentAudioName1 = path.split("/")[path.split("/").length - 1];
    });
  }

  void saveSettingsValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("dbValue", _currentDbValue);
    prefs.setDouble("persecValue", _currentPerSecValue);
    prefs.setDouble("timesampleValue", _currentTimeSampleValue);
    prefs.setString("audioname1Value", _currentAudioName1);
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
          Text("Audio Alert On Treshold"),
          audioChooseControl(),
          FlatButton(
              onPressed: () => saveSettingsValues(),
              child: Text("Save Settings"))
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
            onPressed: () => openAudioPicker(),
          ),
        ),
        Flexible(
          child: GestureDetector(
              onTap: () => openAudioPicker(),
              child: Text(this._currentAudioName1)),
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
              value: _currentDbValue,
              label: _currentDbValue.round().toString(),
              onChanged: (double val) {
                setState(() {
                  _currentDbValue = val;
                });
              }),
        ),
        Container(
          width: 30,
          child: TextField(
            controller:
                TextEditingController(text: _currentDbValue.round().toString()),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'dB'),
            onChanged: (String text) {
              if (double.parse(text) >= minVal &&
                  double.parse(text) <= maxVal) {
                setState(() {
                  _currentDbValue = double.parse(text);
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
              value: _currentPerSecValue,
              label: _currentPerSecValue.round().toString(),
              onChanged: (double val) {
                setState(() {
                  _currentPerSecValue = val;
                });
              }),
        ),
        Container(
          width: 30,
          child: TextField(
            controller: TextEditingController(
                text: _currentPerSecValue.round().toString()),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'dB'),
            onChanged: (String text) {
              if (double.parse(text) >= minVal &&
                  double.parse(text) <= maxVal) {
                setState(() {
                  _currentPerSecValue = double.parse(text);
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
              value: _currentTimeSampleValue,
              label: _currentTimeSampleValue.round().toString(),
              onChanged: (double val) {
                setState(() {
                  _currentTimeSampleValue = val;
                });
              }),
        ),
        Container(
          width: 30,
          child: TextField(
            controller: TextEditingController(
                text: _currentTimeSampleValue.round().toString()),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'dB'),
            onChanged: (String text) {
              if (double.parse(text) >= minVal &&
                  double.parse(text) <= maxVal) {
                setState(() {
                  _currentTimeSampleValue = double.parse(text);
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

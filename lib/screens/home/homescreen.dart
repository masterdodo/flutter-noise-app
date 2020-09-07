import 'package:noise_meter/noise_meter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  String _currentAudioName =
      "Choose audio file..."; //current audio name(without path)

  String _dBValueRealTime; //realtime dB value when recording

  List<double> dBValueList; //array of realtime values for chosen time frame
  int arrLength; //length of array based on time frame and persec value

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

  //Sets a timer of how often to write dB value to array based on chosen persec value
  void getdBData() {
    setState(() {
      timer = Timer.periodic(
          Duration(milliseconds: (1000 / activePerSecValue).round()),
          (Timer t) {
        dBProcessor(_dBValueRealTime);
      });
    });
  }

  //Listens to MIC(gets decibel data)
  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        _isRecording = true;
      }
      _dBValueRealTime = noiseReading.meanDecibel.toString();
    });
  }

  //Turn MIC on
  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
      setState(() {
        //Sets active values from sliders and calculates the length of an array
        activeDbValue = _currentDbValue;
        activePerSecValue = _currentPerSecValue;
        activeTimeSampleValue = _currentTimeSampleValue;
        activeAudioFile = absAudioPath;
        arrLength = (activePerSecValue * activeTimeSampleValue).floor();
        dBValueList = new List<double>();
      });
      getdBData(); //Calls function to start persec timer
    } catch (err) {
      print(err);
    }
  }

  //Turn MIC off
  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel(); //Cancels MIC
        _noiseSubscription = null;
      }
      timer.cancel(); //Stops timer that's adding dB values to array
      stopAudio(); //Stops audio alert if playing
      dBValueList.clear(); //Clears/Resets array of realtime dB values
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  //Play audio file
  void playAudio() async {
    await audioPlayer.play(activeAudioFile, isLocal: true);
  }

  //Stops audio file
  void stopAudio() async {
    await audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text("Noise App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          FlatButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              child: Text("Settings"))
        ]),
      ),
      floatingActionButton: buildActionMicButton(),
    );
  }

  // Widget mic button
  FloatingActionButton buildActionMicButton() {
    return FloatingActionButton(
        backgroundColor: _isRecording ? Colors.red : Colors.green,
        onPressed: _isRecording ? this.stop : this.start,
        child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic));
  }

  // Processes dB values to check average volume
  void dBProcessor(text) {
    if (dBValueList.length == arrLength) {
      dBValueList.removeAt(0);
    }
    dBValueList.add(double.parse(text));
    if (dBValueList.length == arrLength) {
      double avg = 0;
      for (double x in dBValueList) {
        avg += x;
      }
      avg /= dBValueList.length;
      if (avg > activeDbValue) {
        playAudio();
      }
    }
  }
}

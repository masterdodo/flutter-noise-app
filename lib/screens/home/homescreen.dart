import 'package:noise_meter/noise_meter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
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
          Duration(milliseconds: (activePerSecValue * 1000).round()),
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
        arrLength = ((1.0 / activePerSecValue) * activeTimeSampleValue).floor();
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

  //Used to choose audio file, then sets the path of file and gets just the name of the file
  void openAudioPicker() async {
    String path = await FilePicker.getFilePath(type: FileType.audio);
    setState(() {
      absAudioPath = path;
      _currentAudioName = path.split("/")[path.split("/").length - 1];
    });
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
          Text("dB Treshold"),
          dBTresholdSliderControl(30, 150),
          Text("Check For Value Per Second"),
          perSecSliderControl(0.1, 1),
          Text("Time Frame To Check Treshold"),
          timeSampleSliderControl(5, 600),
          Text("Audio Alert On Treshold"),
          audioChooseControl()
        ]),
      ),
      floatingActionButton: buildActionMicButton(),
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
              child: Text(this._currentAudioName)),
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
              value: _currentPerSecValue,
              label: _currentPerSecValue.toStringAsFixed(2),
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
                text: _currentPerSecValue.toStringAsFixed(2)),
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

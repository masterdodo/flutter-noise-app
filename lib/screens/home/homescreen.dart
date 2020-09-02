import 'package:noise_meter/noise_meter.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecording = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter = new NoiseMeter();
  final controller = TextEditingController();
  String text = "";
  Color bgColor = Colors.white;
  final player = AudioCache();
  AudioPlayer audioPlayer;
  Timer timer;
  int lastTimeBell = 0;
  String absAudioPath, activeAudioFile;
  double _currentDbValue = 70;
  double _currentPerSecValue = 1;
  double _currentTimeSampleValue = 60;
  double activeDbValue, activePerSecValue, activeTimeSampleValue;
  String _currentAudioName = "Choose audio file...";
  List<double> dBValueList;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  //Listens to MIC(gets decibel data)
  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
    });
    this.changeText(noiseReading.meanDecibel.toString());
  }

  //Turn MIC on
  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
      setState(() {
        activeDbValue = _currentDbValue;
        activePerSecValue = _currentPerSecValue;
        activeTimeSampleValue = _currentTimeSampleValue;
        activeAudioFile = absAudioPath;
      });
      double arrLengthDouble = (1 / activePerSecValue) * activeTimeSampleValue;
      int arrLength = arrLengthDouble.round();
      dBValueList = new List(arrLength);
    } catch (err) {
      print(err);
    }
  }

  //Turn MIC off
  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      stopAudio();
      this.setState(() {
        this._isRecording = false;
        this.bgColor = Colors.white;
        this.text = "";
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void openAudioPicker() async {
    String path = await FilePicker.getFilePath(type: FileType.audio);
    setState(() {
      absAudioPath = path;
      _currentAudioName = path.split("/")[path.split("/").length - 1];
    });
  }

  void playAudio() async {
    await audioPlayer.play(activeAudioFile, isLocal: true);
  }

  void stopAudio() async {
    await audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Noise App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          dBTresholdSliderControl(30, 150),
          perSecSliderControl(0.1, 1),
          timeSampleSliderControl(5, 600),
          Row(
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
          )
        ]),
      ),
      floatingActionButton: buildActionMicButton(),
    );
  }

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

  FloatingActionButton buildActionMicButton() {
    return FloatingActionButton(
        backgroundColor: _isRecording ? Colors.red : Colors.green,
        onPressed: _isRecording ? this.stop : this.start,
        child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic));
  }

  void changeText(text) {
    var db = double.parse(text);
    if (db > activeDbValue) {
      bgColor = Colors.red[300];
      if (currentTimeInSeconds() > lastTimeBell + 3) {
        playAudio();
        lastTimeBell = currentTimeInSeconds();
      }
    }
    setState(() {
      this.text = text;
    });
  }

  static int currentTimeInSeconds() {
    var ms = (new DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }
}

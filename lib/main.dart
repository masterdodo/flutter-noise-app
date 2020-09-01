import 'package:noise_meter/noise_meter.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noise App',
      theme: buildThemeData(),
      home: NoiseMain(),
    );
  }

  ThemeData buildThemeData() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

class NoiseMain extends StatefulWidget {
  @override
  _NoiseMainState createState() => _NoiseMainState();
}

class _NoiseMainState extends State<NoiseMain> {
  bool _isRecording = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter = new NoiseMeter();
  final controller = TextEditingController();
  String text = "";
  Color bgColor = Colors.white;
  final player = AudioCache();
  Timer timer;
  int lastTimeBell = 0;
  double _currentDbValue = 70;
  double _currentPerSecValue = 1;
  double _currentTimeSampleValue = 60;
  double activeDbValue, activePerSecValue, activeTimeSampleValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

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
      });
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
      this.setState(() {
        this._isRecording = false;
        this.bgColor = Colors.white;
        this.text = "";
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
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
          timeSampleSliderControl(5, 600)
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
    if (db < 40) {
      bgColor = Colors.green[300];
    } else if (db > 40 && db < 75) {
      bgColor = Colors.orange[300];
    } else if (db > 75) {
      bgColor = Colors.red[300];
      if (currentTimeInSeconds() > lastTimeBell + 3) {
        player.play('audio/bell1.mp3');
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

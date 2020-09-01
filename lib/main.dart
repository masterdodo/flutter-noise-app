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

  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (err) {
      print(err);
    }
  }

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
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(this.text),
        ]),
      ),
      floatingActionButton: buildActionMicButton(),
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

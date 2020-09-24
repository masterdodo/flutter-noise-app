import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_app/app_localizations.dart';
import 'package:noise_app/components/my_drawer.dart';
import 'package:noise_meter/noise_meter.dart';

class ToolsScreen extends StatefulWidget {
  @override
  _ToolsScreenState createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  bool _isRecording;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter;

  bool _isRunning;
  var sw = Stopwatch();

  String maxDb;
  String meanDb;
  String stopwatchDisplay;

  Color _bgColor;

  @override
  void initState() {
    super.initState();
    _noiseMeter = new NoiseMeter();
    _isRecording = false;
    _isRunning = false;
    maxDb = "30.00";
    meanDb = "30.00";
    stopwatchDisplay = "00:00:00";
    _bgColor = Colors.white;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (exception) {
      print(exception);
    }
  }

  void stop() {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
    });
    setState(() {
      this.maxDb = noiseReading.maxDecibel.toStringAsFixed(2);
      this.meanDb = noiseReading.meanDecibel.toStringAsFixed(2);
    });
  }

  void starttimer() {
    Timer(Duration(seconds: 1), running);
  }

  void running() {
    if (sw.isRunning) {
      starttimer();
    }
    setState(() {
      stopwatchDisplay = sw.elapsed.inHours.toString().padLeft(2, "0") +
          ":" +
          (sw.elapsed.inMinutes % 60).toString().padLeft(2, "0") +
          ":" +
          (sw.elapsed.inSeconds % 60).toString().padLeft(2, "0");
    });
  }

  void start_sw() {
    setState(() {
      _isRunning = true;
    });
    sw.start();
    starttimer();
  }

  void stop_sw() {
    setState(() {
      _isRunning = false;
    });
    sw.stop();
  }

  void reset_sw() {
    sw.reset();
    setState(() {
      stopwatchDisplay = "00:00:00";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      drawer: MyDrawer(),
      appBar: AppBar(
          title: Text(
              AppLocalizations.of(context).translate('menu_tools_string'))),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Text(
                      'Noise Meter',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Average dB",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                  RaisedButton(
                    padding: EdgeInsets.all(15),
                    onPressed: _isRecording ? this.stop : this.start,
                    color: _isRecording ? Colors.red : Colors.green,
                    shape: CircleBorder(),
                    child: _isRecording
                        ? Icon(Icons.stop)
                        : Icon(Icons.play_arrow),
                  ),
                  Text(this.meanDb,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                      )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 20),
                child: Row(
                  children: [
                    Text(
                      'Stopwatch',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RaisedButton(
                    padding: EdgeInsets.all(15),
                    onPressed: _isRunning ? this.stop_sw : this.start_sw,
                    color: _isRunning ? Colors.red : Colors.green,
                    shape: CircleBorder(),
                    child:
                        _isRunning ? Icon(Icons.stop) : Icon(Icons.play_arrow),
                  ),
                  RaisedButton(
                    padding: EdgeInsets.all(15),
                    onPressed: this.reset_sw,
                    color: Colors.blue,
                    shape: CircleBorder(),
                    child: Icon(Icons.clear),
                  ),
                  Text(stopwatchDisplay,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

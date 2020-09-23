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

  String maxDb;
  String meanDb;

  Color _bgColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _noiseMeter = new NoiseMeter();
    _isRecording = false;
    maxDb = "30.00";
    meanDb = "30.00";
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
            ],
          ),
        ),
      ),
    );
  }
}

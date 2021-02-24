import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_app/app_localizations.dart';
import 'package:noise_app/components/my_drawer.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
  String maxDbValue;
  String minDbValue;
  String stopwatchDisplay;

  Color _bgColor;

  @override
  void initState() {
    super.initState();
    _noiseMeter = new NoiseMeter(onError);
    _isRecording = false;
    _isRunning = false;
    maxDb = "30.00";
    meanDb = "30.00";
    maxDbValue = "30.00";
    minDbValue = "150.00";
    stopwatchDisplay = "00:00:00";
    _bgColor = Colors.white;
    this.start();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onError(PlatformException e) {
    print(e.toString());
    _isRecording = false;
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
      if (this.mounted) {
        this.setState(() {
          this._isRecording = false;
        });
      }
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
      if (noiseReading.meanDecibel > double.parse(maxDbValue)) {
        this.maxDbValue = noiseReading.meanDecibel.toStringAsFixed(2);
      }
      if (noiseReading.meanDecibel < double.parse(minDbValue)) {
        this.minDbValue = noiseReading.meanDecibel.toStringAsFixed(2);
      }
    });
  }

  void starttimer() {
    Timer(Duration(seconds: 1), running);
  }

  void running() {
    if (sw.isRunning) {
      starttimer();
    }
    if (this.mounted) {
      setState(() {
        stopwatchDisplay = sw.elapsed.inHours.toString().padLeft(2, "0") +
            ":" +
            (sw.elapsed.inMinutes % 60).toString().padLeft(2, "0") +
            ":" +
            (sw.elapsed.inSeconds % 60).toString().padLeft(2, "0");
      });
    }
  }

  void startSw() {
    setState(() {
      _isRunning = true;
    });
    sw.start();
    starttimer();
  }

  void stopSw() {
    setState(() {
      _isRunning = false;
    });
    sw.stop();
  }

  void resetSw() {
    sw.reset();
    setState(() {
      stopwatchDisplay = "00:00:00";
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        stop();
        stopSw();
        Navigator.pushReplacementNamed(context, "/");
        return false;
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        drawer: MyDrawer(
          stopSound: stop,
        ),
        appBar: AppBar(
          title:
              Text(AppLocalizations.of(context).translate('menu_tools_string')),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 20),
                  child: Text(
                    AppLocalizations.of(context)
                        .translate('noise_meter_string'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(""),
                    Text(
                      "MIN",
                      style: TextStyle(color: Colors.blue),
                    ),
                    Text(
                      "MAX",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    /*RaisedButton(
                      padding: EdgeInsets.all(15),
                      onPressed: _isRecording ? this.stop : this.start,
                      color: _isRecording ? Colors.red : Colors.green,
                      shape: CircleBorder(),
                      child: _isRecording
                          ? Icon(Icons.stop)
                          : Icon(Icons.play_arrow),
                    ),*/
                    Text(
                      this.meanDb,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      this.minDbValue,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      this.maxDbValue,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 200,
                  child: SfRadialGauge(
                      enableLoadingAnimation: true,
                      axes: <RadialAxis>[
                        RadialAxis(
                            minimum: 30,
                            maximum: 120,
                            ranges: <GaugeRange>[
                              GaugeRange(
                                  startValue: 30,
                                  endValue: 60,
                                  color: Colors.green),
                              GaugeRange(
                                  startValue: 60,
                                  endValue: 90,
                                  color: Colors.orange),
                              GaugeRange(
                                  startValue: 90,
                                  endValue: 120,
                                  color: Colors.red)
                            ],
                            pointers: <GaugePointer>[
                              NeedlePointer(
                                enableAnimation: true,
                                value: double.parse(this.meanDb),
                              ),
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                  widget: Container(
                                      child: Text(this.meanDb,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))),
                                  angle: 90,
                                  positionFactor: 0.6)
                            ])
                      ]),
                ),
                Divider(
                  color: Colors.transparent,
                  height: 10,
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 20),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('stopwatch_string'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RaisedButton(
                      padding: EdgeInsets.all(15),
                      onPressed: _isRunning ? this.stopSw : this.startSw,
                      color: _isRunning ? Colors.red : Colors.green,
                      shape: CircleBorder(),
                      child: _isRunning
                          ? Icon(Icons.stop)
                          : Icon(Icons.play_arrow),
                    ),
                    RaisedButton(
                      padding: EdgeInsets.all(15),
                      onPressed: this.resetSw,
                      color: Colors.blue,
                      shape: CircleBorder(),
                      child: Icon(Icons.clear),
                    ),
                    Text(
                      stopwatchDisplay,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

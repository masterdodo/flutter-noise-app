import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  String avgDbValue;
  String stopwatchDisplay;
  List<double> dBValueList = [];
  int arrLength;

  Timer timer;
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
    avgDbValue = "30.00";
    stopwatchDisplay = "00:00:00";
    arrLength = 100;
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
      getdBData();
    } catch (exception) {
      print(exception);
    }
  }

  void getdBData() {
    setState(() {
      timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
        dBProcessor(meanDb);
      });
    });
  }

  void dBProcessor(text) {
    if (dBValueList?.length == arrLength) {
      dBValueList.removeAt(0);
    }
    if (text != null && text != "") {
      dBValueList.add(double.parse(text));
    }

    double avg = 0;
    for (double x in dBValueList) {
      avg += x;
    }
    avg /= dBValueList.length;
    setState(() {
      this.avgDbValue = avg.toStringAsFixed(2);
    });
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
          dBValueList?.clear();
          timer?.cancel();
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

  void resetNoise() {
    setState(() {
      maxDb = "30.00";
      meanDb = "30.00";
      maxDbValue = "30.00";
      minDbValue = "150.00";
      dBValueList?.clear();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 80,
                      child: IconButton(
                        color: Colors.blue,
                        icon: Icon(
                          Icons.info,
                          size: 26,
                        ),
                        onPressed: () {
                          Fluttertoast.cancel();
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)
                                  .translate("noise_info_string"),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              fontSize: 20);
                        },
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)
                          .translate('noise_meter_string'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                        ),
                        child: Text(
                          "RESET",
                          style: TextStyle(fontSize: 14),
                        ),
                        onPressed: this.resetNoise,
                      ),
                    ),
                  ],
                ),
                Container(
                  child: Text(
                    this.meanDb,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(
                  height: 8,
                  color: Colors.transparent,
                ),
                Container(
                  height: 200,
                  child: SfRadialGauge(
                      enableLoadingAnimation: true,
                      axes: <RadialAxis>[
                        RadialAxis(
                            minimum: 0,
                            maximum: 120,
                            ranges: <GaugeRange>[
                              GaugeRange(
                                  startValue: 0,
                                  endValue: 30,
                                  color: Colors.black),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "MIN",
                      style: TextStyle(color: Colors.blue),
                    ),
                    Text(
                      "AVG",
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
                    Text(
                      this.minDbValue,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      this.avgDbValue,
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
                Divider(
                  color: Colors.transparent,
                  height: 10,
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 20),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('stopwatch_string'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: _isRunning ? Colors.red : Colors.green,
                        onPrimary: Colors.black,
                        padding: EdgeInsets.all(15),
                        shape: CircleBorder(),
                      ),
                      onPressed: _isRunning ? this.stopSw : this.startSw,
                      child: _isRunning
                          ? Icon(Icons.stop)
                          : Icon(Icons.play_arrow),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.black,
                        padding: EdgeInsets.all(15),
                        shape: CircleBorder(),
                      ),
                      onPressed: this.resetSw,
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

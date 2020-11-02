import 'package:noise_app/app_localizations.dart';
import 'package:noise_app/components/my_drawer.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume/volume.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:share/share.dart';
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
  AudioManager audioManager;
  final assetPlayer = AudioCache();

  final audioString = "Choose audio file...";
  Duration duration;

  double _audioVolumeMinValue = 1;
  double _audioVolumeMaxValue = 100;
  final audioVolumeController = TextEditingController(); //text controller
  Timer timer; //timer used for persec dB checks

  final snackBarNoAudio = SnackBar(
    content: Text(
      "No audio. Select it in the settings!",
      style: TextStyle(color: Colors.black),
    ),
    backgroundColor: Colors.redAccent[400],
    duration: Duration(seconds: 2),
  );

  Color _bgColor = Colors.white; //default bg color of app
  //elected audio files after recording started
  String _activeAudioFile1, _activeAudioFile2, _activeAudioFile3;
  // units(seconds, minutes, hours)
  String _activePerSecUnit, _activeTimeSampleUnit, _activeTimeoutUnit;
  // values
  int _activeDbValue,
      _activePerSecValue,
      _activeTimeSampleValue,
      _activeAudioVolumeValue;
  int _timeLastAudioPlayed = 0;
  int _activeTimeoutValue;

  int maxVol, currentVol;

  String _dBValueRealTime; //realtime dB value when recording

  List<double> dBValueList =
      []; //array of realtime values for chosen time frame
  int arrLength; //length of array based on time frame and persec value

  FlutterLocalNotificationsPlugin fltrNotification;

  Map<String, int> _defaultSounds = {
    "audio/Bleep.mp3": 2,
    "audio/Censor-beep-3.mp3": 1,
    "audio/Foghorn.mp3": 5,
    "audio/Grocery-Scanning.mp3": 4
  };

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _noiseMeter = new NoiseMeter();
    preferencesOnInit();
    _isRecording = false;
    arrLength = 0;
    audioManager = AudioManager.STREAM_MUSIC;
    initAudioStreamType();
    updateVolumes();
    audioVolumeController.addListener(_setAudioVolumeValue);

    //Notification init
    var androidInitilize = new AndroidInitializationSettings('app_icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initializationSettings,
        onSelectNotification: notificationSelected);
  }

  @override
  void dispose() {
    super.dispose();
    audioVolumeController.dispose();
  }

  _setAudioVolumeValue() {
    if (double.parse(audioVolumeController.text).roundToDouble() >=
            _audioVolumeMinValue &&
        double.parse(audioVolumeController.text).roundToDouble() <=
            _audioVolumeMaxValue) {
      setState(() {
        _activeAudioVolumeValue =
            double.parse(audioVolumeController.text).round();
      });
    }
  }

  Future preferencesOnInit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _activeDbValue = prefs.getInt("dbValue") ?? 66;
    _activePerSecValue = prefs.getInt("persecValue") ?? 5;
    _activePerSecUnit = prefs.getString("persecUnit") ?? 'sec';
    _activeTimeSampleValue = prefs.getInt("timesampleValue") ?? 1;
    _activeTimeSampleUnit = prefs.getString("timesampleUnit") ?? 'sec';
    _activeTimeoutValue = prefs.getInt("timeoutValue") ?? 6;
    _activeTimeoutUnit = prefs.getString("timeoutUnit") ?? 'sec';
    _activeAudioVolumeValue = prefs.getInt("audiovolumeValue") ?? 70;
    _activeAudioFile1 =
        prefs.getString("audioname1Value") ?? 'audio/Grocery-Scanning.mp3';
    _activeAudioFile2 =
        prefs.getString("audioname2Value") ?? 'audio/Foghorn.mp3';
    _activeAudioFile3 =
        prefs.getString("audioname3Value") ?? 'audio/Censor-beep-3.mp3';

    prefs.setInt("dbValue", _activeDbValue);
    prefs.setInt("persecValue", _activePerSecValue);
    prefs.setString("persecUnit", _activePerSecUnit);
    prefs.setInt("timesampleValue", _activeTimeSampleValue);
    prefs.setString("timesampleUnit", _activeTimeSampleUnit);
    prefs.setInt("timeoutValue", _activeTimeoutValue);
    prefs.setString("timeoutUnit", _activeTimeoutUnit);
    prefs.setInt("audiovolumeValue", _activeAudioVolumeValue);
    prefs.setString("audioname1Value", _activeAudioFile1);
    prefs.setString("audioname2Value", _activeAudioFile2);
    prefs.setString("audioname3Value", _activeAudioFile3);

    audioVolumeController.text = _activeAudioVolumeValue.round().toString();
  }

  Future notificationSelected(String payload) async {
    //await Navigator.pushNamed(context, '/');
  }

  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Snorty", "Microphone On",
        ongoing: true, enableVibration: false, playSound: false);
    var iOSdetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iOSdetails);

    await fltrNotification.show(
        0, "Snorty", "Microphone On", generalNotificationDetails);
  }

  Future _hideNotification() async {
    await fltrNotification.cancel(0);
  }

  Future<void> initAudioStreamType() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  updateVolumes() async {
    maxVol = await Volume.getMaxVol;
    currentVol = await Volume.getVol;
    setState(() {});
  }

  setVol(int i) async {
    int _setVol = (this.maxVol * (i / 100)).round();
    await Volume.setVol(_setVol, showVolumeUI: ShowVolumeUI.HIDE);
  }

  //Sets a timer of how often to write dB value to array based on chosen persec value
  void getdBData() {
    setState(() {
      timer = Timer.periodic(
          Duration(milliseconds: (1000 / _activePerSecValue).round()),
          (Timer t) {
        dBProcessor(_dBValueRealTime);
      });
    });
  }

  void sendMail() {
    Share.share(AppLocalizations.of(context).translate('share_string'));
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
  void start(context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString("audioname1Value") == null ||
          prefs.getString("audioname1Value") == audioString) {
        Scaffold.of(context).showSnackBar(snackBarNoAudio);
      } else {
        _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
        setState(() {
          //Sets active values from sliders and calculates the length of an array
          _activeDbValue = prefs.getInt("dbValue") ?? 30;
          _activePerSecValue = prefs.getInt("persecValue") ?? 1;
          _activePerSecUnit = prefs.getString("persecUnit") ?? 'sec';
          if (_activePerSecUnit == 'min') {
            _activePerSecValue *= 60;
          } else if (_activePerSecUnit == 'hr') {
            _activePerSecValue *= 3600;
          }
          _activeTimeSampleValue = prefs.getInt("timesampleValue") ?? 1;
          _activeTimeSampleUnit = prefs.getString("timesampleUnit") ?? 'sec';
          if (_activeTimeSampleUnit == 'min') {
            _activeTimeSampleValue *= 60;
          } else if (_activeTimeSampleUnit == 'hr') {
            _activeTimeSampleValue *= 3600;
          }
          _activeTimeoutValue = prefs.getInt("timeoutValue") ?? 1;
          _activeTimeoutUnit = prefs.getString("timeoutUnit") ?? 'sec';
          if (_activeTimeoutUnit == 'min') {
            _activeTimeoutValue *= 60;
          } else if (_activeTimeoutUnit == 'hr') {
            _activeTimeoutValue *= 3600;
          }
          _activeAudioFile1 = prefs.getString("audioname1Value") ?? '';
          _activeAudioFile2 = prefs.getString("audioname2Value") ?? '';
          _activeAudioFile3 = prefs.getString("audioname3Value") ?? '';
          setVol(_activeAudioVolumeValue);
          arrLength = (_activePerSecValue * _activeTimeSampleValue).floor();
          dBValueList = new List<double>();
          _showNotification();
        });
        getdBData(); //Calls function to start persec timer
      }
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
      timer?.cancel(); //Stops timer that's adding dB values to array
      stopAudio(); //Stops audio alert if playing
      dBValueList?.clear(); //Clears/Resets array of realtime dB values
      _hideNotification(); //Clears mic on notification
      this.setState(() {
        this._isRecording = false;
        this._timeLastAudioPlayed = 0;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  //Play audio file
  void playAudio() async {
    if (_defaultSounds.containsKey(_activeAudioFile1)) {
      await assetPlayer.play(_activeAudioFile1);
      setState(() =>
          duration = Duration(seconds: _defaultSounds[_activeAudioFile1]));
    } else {
      await audioPlayer.play(_activeAudioFile1, isLocal: true);
      audioPlayer.onDurationChanged.listen((Duration d) {
        setState(() => duration = d);
      });
    }
  }

  //Stops audio file
  void stopAudio() async {
    await audioPlayer?.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('main_string')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              padding: EdgeInsets.all(45),
              color: _isRecording ? Colors.red : Colors.green,
              shape: CircleBorder(),
              onPressed: _isRecording ? this.stop : () => this.start(context),
              child: _isRecording
                  ? Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 50,
                    )
                  : Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 50,
                    ),
            ),
            Divider(
              color: Colors.transparent,
            ),
            Text(
              "Start/Stop",
              style: TextStyle(fontSize: 18),
            ),
            Divider(
              height: 60,
              color: Colors.transparent,
            ),
            AbsorbPointer(absorbing: _isRecording, child: soundVolume(context))
          ],
        ),
      ),
    );
  }

  Container soundVolume(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Text(AppLocalizations.of(context).translate('sound_volume_string'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          audioVolumeSliderControl(_audioVolumeMinValue, _audioVolumeMaxValue),
        ],
      ),
    );
  }

  Row audioVolumeSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
        Flexible(
          child: Slider(
              activeColor: (_isRecording) ? Colors.grey[300] : Colors.blue,
              inactiveColor:
                  (_isRecording) ? Colors.grey[300] : Colors.blue[100],
              min: minVal,
              max: maxVal,
              divisions: (maxVal - minVal).round(),
              value: _activeAudioVolumeValue.toDouble() ?? 70,
              label: _activeAudioVolumeValue.toString() ?? "70",
              onChanged: (double val) {
                setState(() {
                  _activeAudioVolumeValue = val.round();
                  audioVolumeController.text = val.round().toString();
                });
              }),
        ),
        Container(
          width: 30,
          child: TextField(
            controller: audioVolumeController,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '0'),
            onChanged: (String text) {
              if (double.parse(text) >= minVal &&
                  double.parse(text) <= maxVal) {
                setState(() {
                  _activeAudioVolumeValue = int.parse(text);
                });
              }
            },
          ),
        ),
        Container(
            child: Text(
          "%",
          style: TextStyle(
            fontSize: 18,
          ),
        )),
      ],
    );
  }

  // Processes dB values to check average volume
  void dBProcessor(text) {
    if (duration != null &&
        (_timeLastAudioPlayed + duration.inSeconds >
            (new DateTime.now().millisecondsSinceEpoch / 1000).round())) {
    } else {
      dBProcessorAfterSound(text);
    }
  }

  void dBProcessorAfterSound(text) {
    if (dBValueList?.length == arrLength) {
      dBValueList.removeAt(0);
    }
    dBValueList.add(double.parse(text));
    if (dBValueList?.length == arrLength) {
      double avg = 0;
      for (double x in dBValueList) {
        avg += x;
      }
      avg /= dBValueList.length;
      int x = ((new DateTime.now()).millisecondsSinceEpoch / 1000).round();
      if (avg > _activeDbValue &&
          x > _timeLastAudioPlayed + _activeTimeoutValue) {
        playAudio();
        _timeLastAudioPlayed =
            ((new DateTime.now()).millisecondsSinceEpoch / 1000).round();
        dBValueList.clear();
      }
    }
  }
}

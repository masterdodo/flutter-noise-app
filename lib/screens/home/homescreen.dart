import 'package:noise_app/app_localizations.dart';
import 'package:noise_app/components/my_drawer.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:volume/volume.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:share/share.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isRecording; //mic button recording on or off
  bool _isTimerRunning; //delay timer on or off
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
  String delayForTimer;

  String _bestAudioFile;
  String delayAfterStart;
  Timer delayTimer;

  int dateOnTurnOff;

  int soundCounter;

  int maxVol, currentVol;

  String _dBValueRealTime = ""; //realtime dB value when recording

  List<double> dBValueList =
      []; //array of realtime values for chosen time frame
  int arrLength; //length of array based on time frame and persec value

  FlutterLocalNotificationsPlugin fltrNotification;

  Map<String, int> _defaultSounds = {
    "audio/Bleep.mp3": 2,
    "audio/Censor-beep-3.mp3": 1,
    "audio/Foghorn.mp3": 5,
    "audio/Grocery-Scanning.mp3": 4,
    "audio/Snort-1.mp3": 4,
    "audio/Snort-2.mp3": 2,
    "audio/Snort-3.mp3": 7
  };

  int recordingAlarmId = 1;

  //ADS
  BannerAd _bannerAd;
  static const MobileAdTargetingInfo targetInfo = MobileAdTargetingInfo();

  BannerAd createBannerAd() {
    return BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        targetingInfo: targetInfo,
        size: AdSize.smartBanner,
        listener: (MobileAdEvent event) {
          print('Banner Event: $event');
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    audioPlayer = AudioPlayer();
    _noiseMeter = new NoiseMeter(onError);
    preferencesOnInit();
    _isRecording = false;
    _isTimerRunning = false;
    arrLength = 0;
    audioManager = AudioManager.STREAM_MUSIC;
    initAudioStreamType();
    updateVolumes();
    audioVolumeController.addListener(_setAudioVolumeValue);
    soundCounter = 0;
    _bestAudioFile = null;
    setState(() {
      this.delayAfterStart = delayAfterStart;
      this.delayForTimer = delayAfterStart;
    });

    //Notification init
    var androidInitilize = new AndroidInitializationSettings('app_icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initializationSettings,
        onSelectNotification: notificationSelected);
    //Ads
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-4998785370755707~2117070259");
    _bannerAd = createBannerAd()..load();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    audioVolumeController.dispose();
    _bannerAd.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (dateOnTurnOff != null && _isTimerRunning) {
          int x =
              (((new DateTime.now()).millisecondsSinceEpoch) / 1000).round() -
                  dateOnTurnOff;
          int min = (x / 60).floor();
          int sec = (x % 60);
          delayForTimer = (int.parse(delayForTimer.split(":")[0]) - min)
                  .toString()
                  .padLeft(2, '0') +
              ":" +
              ((int.parse(delayForTimer.split(":")[1]) - sec < 0)
                      ? ''
                      : (int.parse(delayForTimer.split(":")[1]) - sec))
                  .toString()
                  .padLeft(2, '0');
          preStartCountdown(context);
        }
        break;
      case AppLifecycleState.paused:
        dateOnTurnOff =
            (((new DateTime.now()).millisecondsSinceEpoch) / 1000).round();
        if (_isTimerRunning) {
          stopTheTimer();
        }
        break;
      default:
        break;
    }
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
    _activeAudioVolumeValue = prefs.getInt("audiovolumeValue") ?? 83;
    _activeAudioFile1 =
        prefs.getString("audioname1Value") ?? 'audio/Grocery-Scanning.mp3';
    _activeAudioFile2 =
        prefs.getString("audioname2Value") ?? 'audio/Foghorn.mp3';
    _activeAudioFile3 =
        prefs.getString("audioname3Value") ?? 'audio/Censor-beep-3.mp3';
    _bestAudioFile =
        prefs.getString("audioname1Value") ?? 'audio/Grocery-Scanning.mp3';
    delayAfterStart = prefs.getString("delayAfterStart") ?? '00:00';

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
    prefs.setString("delayAfterStart", delayAfterStart);

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
        _isTimerRunning = false;
      }
      _dBValueRealTime = noiseReading.meanDecibel.toString();
    });
  }

  void onError(PlatformException e) {
    print(e.toString());
    _isRecording = false;
    _isTimerRunning = false;
  }

  void preStart(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTimerRunning = true;
      soundCounter = 0;
    });
    prefs.setString("delayAfterStart", delayAfterStart);
    setState(() {
      delayForTimer = delayAfterStart;
    });
    if (delayAfterStart == "00:00") {
      start();
    } else {
      int x = int.parse(delayAfterStart.split(":")[0]);
      print(x);
      AndroidAlarmManager.cancel(recordingAlarmId);
      AndroidAlarmManager.oneShot(
        Duration(seconds: x),
        recordingAlarmId,
        fireAlarm,
      );
      preStartCountdown(context);
    }
  }

  void preStartCountdown(context) {
    delayTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (int.parse(delayForTimer.split(":")[1]) == 0 &&
          int.parse(delayForTimer.split(":")[0]) != 0) {
        delayForTimer = (int.parse(delayForTimer.split(":")[0]) - 1)
                .toString()
                .padLeft(2, "0") +
            ":59";
      } else {
        delayForTimer = (int.parse(delayForTimer.split(":")[0]))
                .toString()
                .padLeft(2, "0") +
            ":" +
            (int.parse(delayForTimer.split(":")[1]) - 1)
                .toString()
                .padLeft(2, "0");
      }
      setState(() {
        this.delayForTimer = delayForTimer;
      });
      if (delayForTimer == "00:00") {
        delayTimer?.cancel();
        start();
      }
    });
  }

  void stopTheTimer() {
    delayTimer?.cancel();
  }

  //Turn MIC on
  void start() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
      setState(() {
        //Sets active values from sliders and calculates the length of an array
        soundCounter = 0;
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
      delayTimer?.cancel();
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
      timer?.cancel(); //Stops timer that's adding dB values to array
      delayTimer?.cancel();
      stopAudio(); //Stops audio alert if playing
      dBValueList?.clear(); //Clears/Resets array of realtime dB values
      _hideNotification(); //Clears mic on notification
      this.setState(() {
        this._isRecording = false;
        this._isTimerRunning = false;
        this._timeLastAudioPlayed = 0;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  //Play audio file
  void playAudio() async {
    setState(() {
      soundCounter++;
    });
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
    Timer(Duration(seconds: 3), () {
      try {
        if (this.mounted) {
          _bannerAd?.show();
        }
      } catch (e) {
        print("Yikes");
      }
    });
    return WillPopScope(
      onWillPop: () async {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)
                      .translate("exit_app_string")),
                  actions: [
                    TextButton(
                      child: Text(
                          AppLocalizations.of(context).translate("no_string")),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: Text(
                          AppLocalizations.of(context).translate("yes_string")),
                      onPressed: () => Navigator.pop(context, true),
                    )
                  ],
                ));
      },
      child: Scaffold(
        drawerEdgeDragWidth: (!_isRecording && !_isTimerRunning) ? 20.0 : 0.0,
        backgroundColor: _bgColor,
        drawer: (_noiseSubscription != null) ? null : MyDrawer(),
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('main_string')),
          automaticallyImplyLeading: (!_isRecording && !_isTimerRunning),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                soundCounter.toString().padLeft(3, '0'),
                style: TextStyle(fontSize: 35),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      primary: _isRecording
                          ? Colors.red
                          : (_isTimerRunning
                              ? Colors.deepPurple[800]
                              : Colors.green),
                      padding: EdgeInsets.all(35),
                    ),
                    onPressed: (_isRecording || _isTimerRunning)
                        ? this.stop
                        : () => this.preStart(context),
                    child: (_isRecording || _isTimerRunning)
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
                  AbsorbPointer(
                    absorbing: _isRecording || _isTimerRunning,
                    child: (_isRecording || _isTimerRunning)
                        ? Text(
                            (this.delayForTimer == "00:00")
                                ? ""
                                : "- " + this.delayForTimer,
                            style: TextStyle(fontSize: 20),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 7.0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate("delay_timer_string"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: (delayAfterStart == '00:00'
                                      ? '0 min'
                                      : (delayAfterStart == '15:00')
                                          ? '15 min'
                                          : (delayAfterStart == '30:00')
                                              ? '30 min'
                                              : (delayAfterStart == '45:00')
                                                  ? '45 min'
                                                  : '60 min'),
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 20,
                                  elevation: 16,
                                  style: TextStyle(color: Colors.black),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.blueAccent,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      delayAfterStart = (newValue == '0 min'
                                          ? '00:00'
                                          : (newValue == '15 min')
                                              ? '15:00'
                                              : (newValue == '30 min')
                                                  ? '30:00'
                                                  : (newValue == '45 min')
                                                      ? '45:00'
                                                      : '60:00');
                                    });
                                  },
                                  items: <String>[
                                    '0 min',
                                    '15 min',
                                    '30 min',
                                    '45 min',
                                    '60 min'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  AbsorbPointer(
                      absorbing: _isRecording || _isTimerRunning,
                      child: soundVolume(context))
                ],
              ),
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context).translate('sound_volume_string') +
                    ":",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 6.0),
                width: 32,
                child: TextField(
                  textAlign: TextAlign.end,
                  controller: audioVolumeController,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: '0',
                  ),
                  onChanged: (String text) {
                    if (double.parse(text) >= _audioVolumeMinValue &&
                        double.parse(text) <= _audioVolumeMaxValue) {
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
          ),
          audioVolumeSliderControl(_audioVolumeMinValue, _audioVolumeMaxValue),
        ],
      ),
    );
  }

  Row audioVolumeSliderControl(double minVal, double maxVal) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: GestureDetector(
            onTap: () {
              if (_activeAudioVolumeValue > minVal) {
                setState(() {
                  _activeAudioVolumeValue--;
                  audioVolumeController.text =
                      _activeAudioVolumeValue.toString();
                });
              }
            },
            child: Icon(Icons.remove),
          ),
        ),
        Flexible(
          child: Slider(
              activeColor: (_isRecording || _isTimerRunning)
                  ? Colors.grey[300]
                  : Colors.blue,
              inactiveColor: (_isRecording || _isTimerRunning)
                  ? Colors.grey[300]
                  : Colors.blue[100],
              min: minVal,
              max: maxVal,
              divisions: (maxVal - minVal).round(),
              value: _activeAudioVolumeValue?.toDouble() ?? 70,
              label: _activeAudioVolumeValue?.toString() ?? "70",
              onChanged: (double val) {
                setState(() {
                  _activeAudioVolumeValue = val.round();
                  audioVolumeController.text = val.round().toString();
                });
              }),
        ),
        SizedBox(
          width: 20,
          child: GestureDetector(
            onTap: () {
              if (_activeAudioVolumeValue < maxVal) {
                setState(() {
                  _activeAudioVolumeValue++;
                  audioVolumeController.text =
                      _activeAudioVolumeValue.toString();
                });
              }
            },
            child: Icon(Icons.add),
          ),
        ),
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
    if (text != null && text != "") {
      dBValueList.add(double.parse(text));
    }
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

void fireAlarm() {
  print('Alarm fired at ${DateTime.now()}');
}

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize alarm package
  await Alarm.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Alarm Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: AlarmHomePage(),
    );
  }
}

class AlarmHomePage extends StatefulWidget {
  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _checkAndRequestExactAlarmPermission();
  }

  Future<void> _checkAndRequestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _scheduleAlarm() async {
    DateTime now = DateTime.now();
    DateTime alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // If the selected time is before now, schedule for tomorrow
    if (alarmDateTime.isBefore(now)) {
      alarmDateTime = alarmDateTime.add(Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: 1,
      dateTime: alarmDateTime,
      assetAudioPath: 'assets/sounds/alarm.mp3', 
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: 'Alarm',
        body: 'Your alarm is ringing',
        stopButton: 'Stop',
        icon: 'notification_icon', // put your notification icon name here
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alarm set for ${_selectedTime.format(context)}')),
    );
  }

  Future<void> _cancelAlarm() async {
    await Alarm.stop(1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alarm cancelled')),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Alarm Demo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selected Time: ${_selectedTime.format(context)}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickTime,
              child: Text('Pick Alarm Time'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _scheduleAlarm,
              child: Text('Set Alarm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cancelAlarm,
              child: Text('Cancel Alarm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

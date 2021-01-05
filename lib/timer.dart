import 'dart:async';

import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer _timer;
  int _start = 11;
  String _startString = '0:00';

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start < 1) {
                timer.cancel();
                _start = 11;
                startTimer();
              } else {
                _start = _start - 1;
                if (_start < 10) {
                  _startString = "0:0$_start";
                } else {
                  _startString = "0:$_start";
                }
              }
            }));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return Column(
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            startTimer();
          },
          child: Text("start"),
        ),
        Text("$_startString")
      ],
    );
  }
}

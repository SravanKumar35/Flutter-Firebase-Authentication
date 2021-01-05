import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/home.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class OTPScreen extends StatefulWidget {
  static const String routeName = '/otp';
  final String phone;
  OTPScreen(this.phone);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  Timer _timer;
  int _start = 10;
  bool resend = false;
  bool _isInAsyncCall = false;

  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(235, 236, 237, 1),
    borderRadius: BorderRadius.circular(5.0),
  );

  @override
  void initState() {
    super.initState();
    _verifyPhone();
    startTimer();
  }

  @override
  void dispose() {
    _pinPutFocusNode.dispose();
    super.dispose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            _timer.cancel();
            _start = 10;
            resend = true;
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${widget.phone}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        setState(() {
          _isInAsyncCall = true;
        });
        Future.delayed(Duration(seconds: 2), () async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              _saveUser();
              _timer.cancel();
              setState(() {
                _isInAsyncCall = false;
              });
              Navigator.pushNamed(context, '/home');
            }
          });
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationID, int resendToken) {
        setState(() {
          _verificationCode = verificationID;
        });
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        setState(() {
          _verificationCode = verificationID;
        });
      },
      timeout: Duration(seconds: 60),
    );
  }

  _verifyOTP() async {
    setState(() {
      _isInAsyncCall = true;
    });
    Future.delayed(Duration(seconds: 2), () async {
      try {
        await FirebaseAuth.instance
            .signInWithCredential(PhoneAuthProvider.credential(
                verificationId: _verificationCode,
                smsCode: _pinPutController.text))
            .then((value) async {
          if (value.user != null) {
            _saveUser();
            _timer.cancel();
            setState(() {
              _isInAsyncCall = false;
            });
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
                (route) => false);
          }
        });
      } catch (e) {
        FocusScope.of(context).unfocus();
        _scaffoldkey.currentState
            .showSnackBar(SnackBar(content: Text('Invalid OTP')));
      }
    });
  }

  _saveUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Screen'),
      ),
      body: _body(),
    );
  }

  _body() {
    return ModalProgressHUD(
      inAsyncCall: _isInAsyncCall,
      opacity: 0.5,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 60),
                child: Center(
                  child: Icon(
                    Icons.phone_android,
                    size: 50,
                    color: Color(0xFF00AEEF),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    'Verification',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 14, left: 10, right: 10),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'You will get an OTP via '),
                        TextSpan(
                          text: "SMS",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                            text: ' on your phone number +91 ${widget.phone}'),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: PinPut(
                    validator: (s) {
                      if (s.contains('1')) return null;
                      return 'NOT VALID';
                    },
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                    withCursor: true,
                    fieldsCount: 6,
                    obscureText: "*",
                    fieldsAlignment: MainAxisAlignment.spaceAround,
                    textStyle:
                        const TextStyle(fontSize: 25.0, color: Colors.black),
                    eachFieldMargin: EdgeInsets.all(0),
                    eachFieldWidth: 45.0,
                    eachFieldHeight: 55.0,
                    // onSubmit: (String pin) => _showSnackBar(pin),
                    focusNode: _pinPutFocusNode,
                    controller: _pinPutController,
                    submittedFieldDecoration: pinPutDecoration,
                    selectedFieldDecoration: pinPutDecoration.copyWith(
                      color: Colors.white,
                      border: Border.all(
                        width: 2,
                        color: const Color.fromRGBO(160, 215, 220, 1),
                      ),
                    ),
                    followingFieldDecoration: pinPutDecoration,
                    pinAnimationType: PinAnimationType.scale,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 14, left: 8, right: 8),
                width: double.infinity,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _verifyOTP();
                  },
                  color: Color(0xFF00AEEF),
                ),
              ),
              if (!resend)
                Container(
                  margin: EdgeInsets.only(top: 14, left: 10, right: 10),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Resend OTP in ',
                            style: TextStyle(
                              color: Colors.blueGrey,
                            ),
                          ),
                          TextSpan(
                            text: "${_start}s",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () => print('Resent OTP'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (resend)
                Container(
                  margin: EdgeInsets.only(top: 14, left: 8, right: 8),
                  width: double.infinity,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      resend = false;
                      startTimer();
                      _verifyPhone();
                    },
                    color: Color(0xFF00AEEF),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

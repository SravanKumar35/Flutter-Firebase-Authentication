import 'package:flutter/material.dart';
import 'package:firebase_login/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  static const String routeName = '/login';
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controller = new TextEditingController();
  bool logged = false;

  @override
  void initState() {
    _checkUser();
    super.initState();
  }

  _checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool status = prefs.getBool('isLoggedIn');
    if (status == true) {
      print("User logged in");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
          (route) => false);
    } else if (status == false || status == null) {
      print("User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: _body(),
    );
  }

  _body() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
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
                  text: new TextSpan(
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 14,
                    ),
                    children: <TextSpan>[
                      new TextSpan(text: 'We will send you an '),
                      new TextSpan(
                        text: "One Time Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      new TextSpan(text: ' on your phone number'),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 70,
              margin: EdgeInsets.only(top: 100),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (String txt) {
                  if (txt.length < 10) {
                    return "Please Enter Valid Mobile Number";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  // errorText: ,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  hintText: 'Phone Number',
                  prefix: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('+91'),
                  ),
                ),
                maxLength: 10,
                keyboardType: TextInputType.phone,
                controller: _controller,
              ),
            ),
            Container(
              width: double.infinity,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Get OTP',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  // _validateMobileNumber();
                  if (_validateMobileNumber()) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('mobile_number', _controller.text);
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => OTPScreen(),
                    //   ),

                    Navigator.pushNamed(context, '/otp',
                        arguments: _controller.text);
                  }
                },
                color: Color(0xFF00AEEF),
              ),
            )
          ],
        ),
      ),
    );
  }

  _validateMobileNumber() {
    if (_controller.text.length == 10) {
      return true;
    } else {
      return false;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', false);
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, '/');
            },
          )
        ],
      ),
      body: Center(
        child: Text(uid),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
  }
}

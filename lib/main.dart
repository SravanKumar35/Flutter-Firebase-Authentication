import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_login/route_generator.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().whenComplete(() {
    print('Firebase Initialized');
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: OTPScreen("7842288203"),
      // initialRoute: '/login',
      navigatorKey: _navigatorKey,
      onGenerateRoute: getRoute,
      routes: routes,
    );
  }
}

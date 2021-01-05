import 'package:firebase_login/home.dart';
import 'package:firebase_login/login.dart';
import 'package:firebase_login/otp.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> routes = {
  '/': (BuildContext context) => Login(),
};
Route<dynamic> getRoute(RouteSettings settings) {
  if (settings.name == "/home") {
    return _buildRoute(settings, HomeScreen());
  } else if (settings.name == "/otp") {
    return _buildRoute(
      settings,
      OTPScreen(settings.arguments),
    );
  } else {
    return null;
  }
}

MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
  return MaterialPageRoute(settings: settings, builder: (_) => builder);
}

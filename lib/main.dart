import 'package:flutter/material.dart';
import 'package:orax_hos_sys_app/screens/login_screen.dart';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام التسجيل',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_demo/screens/home_screen.dart';
import 'package:stream_demo/screens/login_screen.dart';
import 'package:stream_demo/screens/received_files.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '@Protocol Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: LoginScreen.id,
        routes: {
          LoginScreen.id: (context) => LoginScreen(),
          HomeScreen.id: (context) => HomeScreen(),
          ReceivedFiles.id: (context) => ReceivedFiles(),
        });
  }
}

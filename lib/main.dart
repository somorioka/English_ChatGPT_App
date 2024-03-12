import 'package:flutter/material.dart';
import 'homescreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('ChatGPT English Generator')),
        body: EnglishGeneratorScreen(),
      ),
    );
  }
}
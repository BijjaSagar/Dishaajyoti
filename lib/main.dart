import 'package:flutter/material.dart';

void main() {
  runApp(const DishaAjyotiApp());
}

class DishaAjyotiApp extends StatelessWidget {
  const DishaAjyotiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DishaAjyoti',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('DishaAjyoti - Career & Life Guidance'),
        ),
      ),
    );
  }
}

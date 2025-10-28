import 'package:flutter/material.dart';

void main() {
  runApp(const KulmaprotoApp());
}

class KulmaprotoApp extends StatelessWidget {
  const KulmaprotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kulmaproto – Pyöränkulmat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kulmaproto – Web-versio'),
      ),
      body: const Center(
        child: Text(
          '✅ Päivitetty versio toimii!\n\nTämä on uusi Flutter Web -build.',
          style: TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

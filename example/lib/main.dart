import 'package:flutter/material.dart';
import 'package:material_wave_slider/material_wave_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('package:material_wave_slider'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: AnimatedSine(
          width: 128.0 * 2,
          height: 128.0,
          repeat: 3,
          painter: SinePainter(
            strokeWidth: 4.0,
            delta: 128.0 / (100.0 / 3.0),
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

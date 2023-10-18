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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  var value = 0.5;
  var running = true;
  final key = GlobalKey<MaterialWaveSliderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material 3 / Material You Slider'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: MaterialWaveSlider(
            key: key,
            value: value,
            onChanged: (e) {
              setState(() {
                value = e;
              });
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (running) {
              running = false;
              key.currentState?.pause();
            } else {
              running = true;
              key.currentState?.resume();
            }
          });
        },
        child: Icon(running ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}

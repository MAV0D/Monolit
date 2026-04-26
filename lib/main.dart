import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/directional_arrow.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: NavigationScreen());
  }
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool _hasStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LARP GPS')),
      body: Stack(
        children: [
          // The main content (The Arrow and status text)
          const Center(child: DirectionalArrow()),

          // The "User Gesture" Overlay
          if (!_hasStarted)
            Container(
              color: Colors.black.withOpacity(0.8),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("START SENSORS"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () async {
                    // 1. Request GPS permission explicitly on tap
                    await Geolocator.requestPermission();

                    // 2. Refresh the UI
                    setState(() {
                      _hasStarted = true;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

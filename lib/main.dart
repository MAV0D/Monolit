import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/directional_arrow.dart';
import 'package:geolocator/geolocator.dart';
import 'providers/location_provider.dart'; // Adjust path if needed

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
        ],
      ),
    );
  }
}

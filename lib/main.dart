import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/directional_arrow.dart';
import 'package:geolocator/geolocator.dart';
import 'providers/location_provider.dart';
import 'providers/direction_provider.dart';

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
  String _setupState = "Zapnout senzory";
  Color _textColor = Color.fromARGB(255, 102, 80, 163);
  final TextEditingController _coordsController = TextEditingController();

  void _updateDestination(WidgetRef ref) {
    final input = _coordsController.text;
    final parts = input.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lon = double.tryParse(parts[1].trim());
      if (lat != null && lon != null) {
        ref.read(destinationProvider.notifier).state = LatLon(lat, lon);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Souřadnice nastaveny!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monolitní navigace -- PROTOTYP')),
      body: Stack(
        children: [
          // The main content (The Arrow and status text)
          const Center(child: DirectionalArrow()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _coordsController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: "Zem. délka, šířka",
                      hintStyle: TextStyle(color: Colors.white30),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(200, 244, 67, 54),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer(
                  builder: (context, ref, _) {
                    return ElevatedButton(
                      onPressed: () => _updateDestination(ref),
                      child: const Text("Ukázat směr"),
                    );
                  },
                ),
              ],
            ),
          ),
          if (!_hasStarted)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: ElevatedButton.icon(
                  icon: _setupState == "Zapnout senzory"
                      ? const Icon(Icons.play_arrow)
                      : const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                  label: Text(_setupState, style: TextStyle(color: _textColor)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    foregroundColor: _textColor,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: _setupState == "Zapnout senzory"
                      ? () async {
                          setState(() {
                            _setupState = "Zapínání GPS...";
                            _textColor = Colors.white;
                          });
                          // GPS permission
                          await Geolocator.requestPermission();
                          // Compass/Motion permission
                          setState(() => _setupState = "Zapínání kompasu...");
                          await requestWebSensorPermission();

                          // First GPS fix
                          setState(() => _setupState = "Získávání pozice...");
                          await Geolocator.getCurrentPosition(
                            locationSettings: const LocationSettings(
                              accuracy: LocationAccuracy.best,
                            ),
                          ).catchError(
                            (e) => print(e),
                          ); // Catch errors if indoors

                          // Refresh UI without overlay
                          setState(() {
                            _hasStarted = true;
                          });
                        }
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

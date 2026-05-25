import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/directional_arrow.dart';
import 'widgets/symbol_keyboard_input.dart'; // Předpokládám tento název pro vaši klávesnici
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
    return MaterialApp(
      title: 'LARP Navigátor',
      theme: ThemeData.dark(), // Tmavé téma se k LARPu hodí skvěle
      home: const NavigationScreen(),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool _sensorsInitialized = false;
  String _setupState = "";

  // Funkce, která inicializuje senzory až po zadání kódu
  Future<void> _initializeSensors() async {
    if (_sensorsInitialized) return;

    setState(() {
      _setupState = "Aktivace kompasu...";
    });
    await requestWebSensorPermission();

    setState(() {
      _setupState = "Zaměřování GPS...";
    });
    await Geolocator.requestPermission();

    await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).catchError((e) {});

    setState(() {
      _sensorsInitialized = true;
      _setupState = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final destination = ref.watch(destinationProvider);
            final isInTargetZone = ref.watch(targetZoneStatusProvider);

            if (destination == null) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Zadejte kód artefaktu",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Klávesnici předáme callback, který se spustí při úspěšném zadání
                      SymbolKeyboardInput(
                        onCodeAccepted: () {
                          _initializeSensors();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            // STAV 2: Kód je zadán, ale senzory se teprve startují
            if (!_sensorsInitialized) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      _setupState,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            // STAV 3: Senzory běží a hráč dorazil na místo (Zóna úspěchu s hysterezí)
            if (isInTargetZone) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 90,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "DORAZIL JSI NA MÍSTO!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Artefakt zajištěn. Vyhledejte fyzickou schránku v okolí.",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Resetujeme stav hystereze
                          ref
                              .read(targetZoneStatusProvider.notifier)
                              .resetZone();
                          // Smazáním cíle se aplikace automaticky přepne zpět na STAV 1 (Klávesnice)
                          ref
                              .read(destinationProvider.notifier)
                              .clearDestination();
                          // Pro další kód chceme, aby se GPS lock udělal rovnou,
                          // senzory už jsou schválené prohlížečem, tak je můžeme nechat true
                        },
                        child: const Text(
                          "Zadat další kód",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const DirectionalArrow();
          },
        ),
      ),
    );
  }
}

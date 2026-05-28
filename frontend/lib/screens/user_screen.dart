import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/user/directional_arrow.dart';
import '../widgets/user/symbol_keyboard_input.dart';
import '../providers/location_provider.dart';
import '../providers/direction_provider.dart';
import '../services/api_service.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  bool _sensorsInitialized = false;
  String _setupState = "";
  late final AppLifecycleListener _lifecycleListener;

  bool _isFirstLoad = true;

  String _enteredCodeFromKeyboard = "";

  DateTime? _startTime;
  String _finalDurationText = "";

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _handleAppReturn();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (int i = 0; i < 10; i++) {
      precacheImage(AssetImage("assets/sym_$i.png"), context);
    }
    precacheImage(const AssetImage("assets/sym_A.png"), context);
    precacheImage(const AssetImage("assets/sym_B.png"), context);
  }

  void _handleAppReturn() async {
    if (_isFirstLoad) {
      _isFirstLoad = false;
      return;
    }

    final destination = ref.read(destinationProvider);

    if (destination != null) {
      setState(() {
        _sensorsInitialized = false;
      });

      await _initializeSensors();
    }
  }

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

    ref.read(trackingEnabledProvider.notifier).enable();

    try {
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
    } catch (e) {}

    setState(() {
      _sensorsInitialized = true;
      _setupState = "";
    });
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
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

            if (isInTargetZone &&
                _startTime != null &&
                _finalDurationText.isEmpty) {
              final duration = DateTime.now().difference(_startTime!);
              _finalDurationText = _formatDuration(duration);
            }

            if (destination != null && !_sensorsInitialized) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      _setupState.isEmpty
                          ? "Obnovování GPS lokace..."
                          : _setupState,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            if (destination == null) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Adresa Monolitu",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SymbolKeyboardInput(
                        submitButtonLabel: "Aktivovat monolit",
                        onCodeChanged: (code) {
                          _enteredCodeFromKeyboard = code;
                        },
                        onCodeAccepted: () async {
                          _initializeSensors();

                          if (_enteredCodeFromKeyboard.length != 12) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Monolit nelze aktivovat."),
                              ),
                            );
                            return;
                          }

                          // Volání API pro ověření 12místného kódu symbolů
                          final coordinates = await ApiService.verifyCode(
                            _enteredCodeFromKeyboard,
                          );

                          if (coordinates == null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Monolit nelze aktivovat."),
                              ),
                            );
                            return;
                          }

                          // Pokud je kód správný, aktualizujeme souřadnice v Riverpodu
                          ref
                              .read(destinationProvider.notifier)
                              .updateDestination(
                                coordinates["lat"]!,
                                coordinates["lon"]!,
                              );

                          _startTime = DateTime.now();
                          _finalDurationText = ""; // Reset předchozího času
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
                    color: Color(0xE894002E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4094002E),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Dorazili jste na místo!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Jakmile najdete monolit, nastavte si budík na $_finalDurationText minut - po tuto dobu vás v okolí monolitu nikdo nemůže rušit.",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF94002E),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(targetZoneStatusProvider.notifier)
                              .resetZone();
                          ref
                              .read(destinationProvider.notifier)
                              .clearDestination();

                          // Vypne GPS hardware, dokud neklepnou na další kód
                          ref.read(trackingEnabledProvider.notifier).disable();
                          setState(() {
                            _sensorsInitialized = false;
                            _startTime = null;
                            _finalDurationText = "";
                          });
                        },
                        child: const Text(
                          "Vydat se na další cestu",
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

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/direction_provider.dart';

class SymbolKeyboardInput extends ConsumerStatefulWidget {
  final VoidCallback onCodeAccepted; // <--- Přidat toto
  const SymbolKeyboardInput({super.key, required this.onCodeAccepted});

  @override
  ConsumerState<SymbolKeyboardInput> createState() =>
      _SymbolKeyboardInputState();
}

class _SymbolKeyboardInputState extends ConsumerState<SymbolKeyboardInput> {
  // Definice symbolů na klávesnici
  final List<String> _symbols = ["0", "1", "2", "3", "4", "5", "6", "7"];

  // 4-místný kód (můžete změnit délku změnou velikosti listu)
  final List<String> _enteredCode = ["", "", "", ""];
  int _currentFocusIndex = 0;

  void _onSymbolTap(String symbol) {
    if (_currentFocusIndex >= _enteredCode.length) return;

    setState(() {
      _enteredCode[_currentFocusIndex] = symbol;
      // Automatický posun na další pole
      if (_currentFocusIndex < _enteredCode.length - 1) {
        _currentFocusIndex++;
      }
    });
  }

  void _onDelete() {
    setState(() {
      _enteredCode[_currentFocusIndex] = "";
      if (_currentFocusIndex > 0) {
        _currentFocusIndex--;
      }
    });
  }

  void _submitCode() {
    final fullCode = _enteredCode.join();
    if (larpDatabase.containsKey(fullCode)) {
      final target = larpDatabase[fullCode]!;
      ref
          .read(destinationProvider.notifier)
          .updateDestination(target.lat, target.lon);

      widget.onCodeAccepted();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Monolit zaměřen! Výchozí bod nastaven.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Neznámá sekvence symbolů!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_enteredCode.length, (index) {
            final isFocused = index == _currentFocusIndex;
            return GestureDetector(
              onTap: () => setState(() => _currentFocusIndex = index),
              child: Container(
                width: 50,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFocused
                        ? Colors.red
                        : Colors.grey.withValues(alpha: 0.5),
                    width: isFocused ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _enteredCode[index],
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 30),

        // keyboard
        SizedBox(
          height: 240,
          width: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Generování tlačítek do kruhu
              ...List.generate(_symbols.length, (index) {
                // Výpočet úhlu pro každé tlačítko
                final double angle =
                    (index * 2 * math.pi / _symbols.length) -
                    (math.pi / 2) +
                    math.pi / 16;
                const double radius = 90.0; // Poloměr kruhu klávesnice

                return Transform.translate(
                  offset: Offset(
                    radius * math.cos(angle),
                    radius * math.sin(angle),
                  ),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFF1F1F1F),
                        side: const BorderSide(color: Colors.red, width: 1),
                      ),
                      onPressed: () => _onSymbolTap(_symbols[index]),
                      child: Text(
                        _symbols[index],
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // deletion button
              IconButton(
                icon: const Icon(
                  Icons.backspace,
                  color: Colors.redAccent,
                  size: 30,
                ),
                onPressed: _onDelete,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // submit
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _submitCode,
          icon: const Icon(Icons.radar),
          label: const Text("Aktivovat souřadnice"),
        ),
      ],
    );
  }
}

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
  final List<String> _symbols = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "A",
    "B",
  ];

  final Map<String, String> _symbolImages = {
    "0": "assets/sym_0.png",
    "1": "assets/sym_0.png",
    "2": "assets/sym_0.png",
    "3": "assets/sym_0.png",
    "4": "assets/sym_0.png",
    "5": "assets/sym_0.png",
    "6": "assets/sym_0.png",
    "7": "assets/sym_0.png",
    "8": "assets/sym_0.png",
    "9": "assets/sym_0.png",
    "A": "assets/sym_0.png",
    "B": "assets/sym_0.png",
  };

  // 4-místný kód (můžete změnit délku změnou velikosti listu)
  final List<String> _enteredCode = [
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  ];
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
      if (_enteredCode[_currentFocusIndex] == "" && _currentFocusIndex > 0) {
        _currentFocusIndex--;
        _enteredCode[_currentFocusIndex] = "";
      } else {
        _enteredCode[_currentFocusIndex] = "";
      }
    });
  }

  void _submitCode() {
    final fullCode = _enteredCode.join();
    if (fullCode.length != 12) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Monolit nelze aktivovat.")));
    } else if (larpDatabase.containsKey(fullCode)) {
      final target = larpDatabase[fullCode]!;
      ref
          .read(destinationProvider.notifier)
          .updateDestination(target.lat, target.lon);

      widget.onCodeAccepted();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Aktivace monolitu úspěšná. Jste přenášeni.")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Monolit nelze aktivovat.")));
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
                padding: const EdgeInsets.all(2),
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
                child: _enteredCode[index].isNotEmpty
                    ? Image.asset(
                        _symbolImages[_enteredCode[index]]!,
                        fit: BoxFit.contain,
                      )
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 50),

        // keyboard
        SizedBox(
          height: 325,
          width: 325,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Generování tlačítek do kruhu
              ...List.generate(_symbols.length, (index) {
                // Výpočet úhlu pro každé tlačítko
                final double angle =
                    (index * 2 * math.pi / _symbols.length) -
                    (math.pi / 2) +
                    math.pi / 12;
                const double radius = 150; // Poloměr kruhu klávesnice

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
                        padding: EdgeInsets.all(6),
                        backgroundColor: const Color(0xFF1F1F1F),
                        side: const BorderSide(color: Colors.red, width: 1),
                      ),
                      onPressed: () => _onSymbolTap(_symbols[index]),
                      child: Image.asset(
                        _symbolImages[_symbols[index]]!,
                        fit: BoxFit.contain,
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
        const SizedBox(height: 50),

        // submit
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _submitCode,
          icon: const Icon(Icons.radar),
          label: const Text("Aktivovat monolit"),
        ),
      ],
    );
  }
}

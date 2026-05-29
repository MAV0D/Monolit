import 'dart:math' as math;
import 'package:flutter/material.dart';

class SymbolKeyboardInput extends StatefulWidget {
  final VoidCallback?
  onCodeAccepted; // Pro hráče: Spustí se po stisku hlavního tlačítka
  final Function(String)?
  onCodeChanged; // Pro admina: Volá se při každé změně kódu
  final String submitButtonLabel; // Přizpůsobitelný text tlačítka
  final String? initialCode; // Možnost předvyplnit kód (např. při editaci)

  const SymbolKeyboardInput({
    super.key,
    this.onCodeAccepted,
    this.onCodeChanged,
    this.submitButtonLabel = "Aktivovat monolit",
    this.initialCode,
  });

  @override
  State<SymbolKeyboardInput> createState() => _SymbolKeyboardInputState();
}

class _SymbolKeyboardInputState extends State<SymbolKeyboardInput> {
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
    "1": "assets/sym_1.png",
    "2": "assets/sym_2.png",
    "3": "assets/sym_3.png",
    "4": "assets/sym_4.png",
    "5": "assets/sym_5.png",
    "6": "assets/sym_6.png",
    "7": "assets/sym_7.png",
    "8": "assets/sym_8.png",
    "9": "assets/sym_9.png",
    "A": "assets/sym_A.png",
    "B": "assets/sym_B.png",
  };

  Map<String, String> symbolBigrams = {
    "0": "Aa",
    "1": "Mi",
    "2": "Si",
    "3": "Or",
    "4": "Ve",
    "5": "Lu",
    "6": "Au",
    "7": "Ti",
    "8": "Cl",
    "9": "Oc",
    "A": "Ca",
    "B": "La",
  };

  late List<String> _enteredCode;
  int _currentFocusIndex = 0;

  @override
  void initState() {
    super.initState();
    _enteredCode = List.generate(12, (_) => "");
    if (widget.initialCode != null && widget.initialCode!.length == 12) {
      for (int i = 0; i < 12; i++) {
        _enteredCode[i] = widget.initialCode![i];
      }
    }
  }

  void _notifyChanged() {
    if (widget.onCodeChanged != null) {
      widget.onCodeChanged!(_enteredCode.join());
    }
  }

  void _onSymbolTap(String symbol) {
    if (_currentFocusIndex >= _enteredCode.length) return;

    setState(() {
      _enteredCode[_currentFocusIndex] = symbol;
      if (_currentFocusIndex < _enteredCode.length - 1) {
        _currentFocusIndex++;
      }
    });
    _notifyChanged();
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
    _notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_enteredCode.length, (index) {
            final isFocused = index == _currentFocusIndex;
            return Flexible(
              child: GestureDetector(
                onTap: () => setState(() => _currentFocusIndex = index),
                child: Container(
                  width: 50,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
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
                          _symbolImages[_enteredCode[index]] ??
                              "assets/sym_0.png",
                          fit: BoxFit.contain,
                        )
                      : null,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 30),

        // Keyboard
        SizedBox(
          height: 300,
          width: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(_symbols.length, (index) {
                final double angle =
                    (index * 2 * math.pi / _symbols.length) -
                    (math.pi / 2) +
                    math.pi / 12;
                const double radius = 125;

                return Transform.translate(
                  offset: Offset(
                    radius * math.cos(angle),
                    radius * math.sin(angle),
                  ),
                  child: SizedBox(
                    width: 45,
                    height: 65,
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                            backgroundColor: const Color(0xFF1F1F1F),
                            side: const BorderSide(color: Colors.red, width: 1),
                          ),
                          onPressed: () => _onSymbolTap(_symbols[index]),
                          child: Image.asset(
                            _symbolImages[_symbols[index]]!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          symbolBigrams[_symbols[index]]!,
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              IconButton(
                icon: const Icon(
                  Icons.backspace,
                  color: Colors.redAccent,
                  size: 26,
                ),
                onPressed: _onDelete,
              ),
            ],
          ),
        ),
        if (widget.onCodeAccepted != null) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: widget.onCodeAccepted,
            icon: const Icon(Icons.radar),
            label: Text(widget.submitButtonLabel),
          ),
        ],
      ],
    );
  }
}

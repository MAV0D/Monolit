import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:monolit_gps/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_token_provider.dart';

class AdminPointFormView extends ConsumerStatefulWidget {
  final int? editPlaceId;

  const AdminPointFormView({super.key, this.editPlaceId});

  @override
  ConsumerState<AdminPointFormView> createState() => _AdminPointFormViewState();
}

class _AdminPointFormViewState extends ConsumerState<AdminPointFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  Future<Map<String, dynamic>?>? _initialDataFuture;
  bool _isFieldsInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.editPlaceId != null) {
      _initialDataFuture = _getPlace(widget.editPlaceId!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _gpsToFields() async {
    _latController.clear();
    _lonController.clear();
    final location = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _latController.text = location.latitude.toString();
      _lonController.text = location.longitude.toString();
    });
  }

  void _saveForm() {
    final token = ref.read(adminTokenProvider)!;

    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      String? code = _codeController.text;
      code = _parseCode(code, false);
      if (code == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Byl zadán neplatný kód. ")));
        return;
      }
      final double lat = double.parse(_latController.text);
      final double lon = double.parse(_lonController.text);

      if (widget.editPlaceId != null) {
        ApiService.editPoint(token, name, code, lat, lon, widget.editPlaceId!);
      } else {
        ApiService.addNewPoint(token, name, code, lat, lon);
      }

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editPlaceId != null
                ? "Monolit byl úspěšně vytvořen"
                : "Monolit byl úspěšně upraven",
          ),
        ),
      );
    }
  }

  String? _parseCode(String code, bool reverse) {
    String parsedCode = "";

    Map<String, String> symbolBigrams = {
      "Aa": "0",
      "Mi": "1",
      "Si": "2",
      "Or": "3",
      "Ve": "4",
      "Lu": "5",
      "Au": "6",
      "Ti": "7",
      "Cl": "8",
      "Oc": "9",
      "Ca": "A",
      "La": "B",
    };
    int chunkSize = 2;
    if (reverse) {
      chunkSize = 1;
      symbolBigrams = symbolBigrams.map((key, value) => MapEntry(value, key));
    }

    for (int i = 0; i < code.length; i += chunkSize) {
      int end = i + chunkSize;
      String bigram = code.substring(i, end);

      if (symbolBigrams.containsKey(bigram)) {
        parsedCode += symbolBigrams[bigram]!;
      } else {
        return null;
      }
    }

    return parsedCode;
  }

  void _initializeControllers(Map<String, dynamic> data) {
    if (_isFieldsInitialized) return;
    _nameController.text = data['name'] ?? '';
    String code = data['code'] ?? '';
    _codeController.text = _parseCode(code, true)!;
    _latController.text = (data['latitude'] ?? '').toString();
    _lonController.text = (data['longitude'] ?? '').toString();
    _isFieldsInitialized = true;
  }

  Future<Map<String, dynamic>?> _getPlace(int id) async {
    final token = ref.read(adminTokenProvider)!;
    final result = await ApiService.getPoint(token, id);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editPlaceId != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1F1F1F),
          title: const Text("Upravit monolit"),
        ),
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _initialDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.red),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text(
                  "Nepodařilo se načíst data ze serveru.",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            _initializeControllers(snapshot.data!);

            return _buildForm();
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text("Nový monolit"),
      ),
      backgroundColor: const Color(0xFF0F0F0F),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.editPlaceId != null
                  ? "Úprava existujícího monolitu"
                  : "Přidat nový monolit",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Název monolitu",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              validator: (val) => val!.isEmpty ? "Zadej název monolitu" : null,
            ),
            const SizedBox(height: 15),

            // 2. Pole pro 24místný kód zkratek
            TextFormField(
              controller: _codeController,
              style: const TextStyle(color: Colors.white),
              maxLength: 24,
              decoration: const InputDecoration(
                labelText: "Kód monolitu (např. AaMiSiOrVeLuAuTiClOcCaLa",
                labelStyle: TextStyle(color: Colors.grey),
                counterStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              validator: (val) =>
                  val!.length != 24 ? "Kód musí mít přesně 24 znaků" : null,
            ),
            const SizedBox(height: 15),

            // 3. Řada pro souřadnice
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Latitude (Zem. šířka)",
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Povinné";
                      }

                      final isNumber = double.tryParse(value);
                      if (isNumber == null) {
                        return "Zadej platné číslo (použij tečku)";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _lonController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Longitude (Zem. délka)",
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Povinné";
                      }

                      final isNumber = double.tryParse(value);
                      if (isNumber == null) {
                        return "Zadej platné číslo (použij tečku)";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 4. Tlačítko pro zaměření GPS telefonu
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _gpsToFields,
              icon: const Icon(Icons.my_location),
              label: const Text("Načíst aktuální polohu"),
            ),
            const SizedBox(height: 40),

            // 5. Hlavní ukládací tlačítko
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _saveForm,
              child: Text(
                widget.editPlaceId != null
                    ? "Uložit změny v bodu"
                    : "Vytvořit bod (neaktivní)",
                style: const TextStyle(
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
}

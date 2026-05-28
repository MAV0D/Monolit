import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monolit_gps/services/api_service.dart';
import '../../providers/admin_token_provider.dart';
import '../../widgets/admin/admin_point_form_view.dart';

class AdminPointsListView extends ConsumerStatefulWidget {
  const AdminPointsListView({super.key});

  @override
  ConsumerState<AdminPointsListView> createState() =>
      _AdminPointsListViewState();
}

class _AdminPointsListViewState extends ConsumerState<AdminPointsListView> {
  // Stavy pro uložení načtených dat a vyhledávání
  List<Map<String, dynamic>> _allPlaces = [];
  List<Map<String, dynamic>> _filteredPlaces = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPlaces() async {
    final token = ref.read(adminTokenProvider)!;
    try {
      final data = await ApiService.getAllPoints(token);
      if (!mounted) return;

      setState(() {
        _allPlaces = data ?? [];
        _filterPlaces(_searchController.text);
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Chyba při načítání bodů";
      });
    }
  }

  void _filterPlaces(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredPlaces = _allPlaces;
      } else {
        _filteredPlaces = _allPlaces.where((place) {
          final name = (place['name'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _changeState(int id, bool newValue) {
    final token = ref.read(adminTokenProvider)!;
    ApiService.changePointStatus(token, id, newValue);
  }

  void _openForm(int? id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPointFormView(editPlaceId: id),
      ),
    );
    _loadPlaces();
  }

  void _deletePoint(BuildContext context, int id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool dialogLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F1F),
              title: const Text(
                "Smazat monolit?",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "Opravdu chcete trvale smazat tento monolit?",
                style: TextStyle(color: Colors.grey),
              ),
              actions: [
                if (!dialogLoading)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Zrušit",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                TextButton(
                  onPressed: dialogLoading
                      ? null
                      : () async {
                          setDialogState(() {
                            dialogLoading = true;
                          });

                          try {
                            final token = ref.read(adminTokenProvider)!;
                            await ApiService.deletePoint(token, id);
                          } catch (e) {}

                          if (!context.mounted) return;

                          setDialogState(() {
                            dialogLoading = false;
                          });

                          Navigator.pop(context);
                          _loadPlaces();
                        },
                  child: dialogLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Smazat",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _parseCode(String code) {
    String parsedCode = "";

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

    for (String char in code.split('')) {
      parsedCode += symbolBigrams[char]!;
    }

    return parsedCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openForm(null);
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        tooltip: "Přidat monolit",
        child: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onChanged: _filterPlaces,
            decoration: InputDecoration(
              hintText: "Vyhledat monolit...",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _filterPlaces('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1F1F1F),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        Expanded(
          child: _filteredPlaces.isEmpty
              ? _allPlaces.isEmpty
                    ? const Center(
                        child: Text(
                          "V systému nejsou žádné monolity.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : const Center(
                        child: Text(
                          "Žádné monolity odpovídající hledání.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = _filteredPlaces[index];

                    return Card(
                      color: const Color(0xFF1F1F1F),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: place["active"] == 1
                              ? Colors.red.withValues(alpha: 0.4)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          place["name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kód: ${_parseCode(place["code"])}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "GPS: ${place["latitude"]}, ${place["longitude"]}",
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Switch(
                          value: place["active"] == 1,
                          activeThumbColor: Colors.red,
                          onChanged: (bool newValue) {
                            setState(() => place["active"] = newValue ? 1 : 0);
                            _changeState(place["id"], newValue);
                          },
                        ),
                        onTap: () {
                          _openForm(place["id"]);
                        },
                        onLongPress: () {
                          _deletePoint(context, place["id"]);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

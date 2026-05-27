import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 1. Soubor s anotací je nezbytný pro generování kódu
part 'admin_token_provider.g.dart';

// 2. Anotace @riverpod automaticky vytvoří "adminTokenProvider"
@riverpod
class AdminToken extends _$AdminToken {
  // 3. Metoda build definuje výchozí stav (na začátku null)
  @override
  String? build() {
    return null;
  }

  // 4. Metoda pro uložení tokenu po úspěšném přihlášení
  void setToken(String token) {
    state = token;
  }

  // 5. Metoda pro smazání tokenu (odhlášení)
  void clearToken() {
    state = null;
  }
}

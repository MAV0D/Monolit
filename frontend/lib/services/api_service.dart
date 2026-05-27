import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "/api";

  static Future<Map<String, double>?> verifyCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/point_location"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"code": code}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "lat": (data["lat"] as num).toDouble(),
          "lon": (data["lon"] as num).toDouble(),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> verifyAdmin(String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/auth"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"password": password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["token"];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static void addNewPoint(
    String token,
    String name,
    String code,
    double lat,
    double lon,
  ) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/admin/new_place"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "name": name,
          "code": code,
          "latitude": lat,
          "longitude": lon,
        }),
      );
    } catch (e) {}
  }

  static void editPoint(
    String token,
    String name,
    String code,
    double lat,
    double lon,
    int id,
  ) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/admin/place/$id/update"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "name": name,
          "code": code,
          "latitude": lat,
          "longitude": lon,
        }),
      );
    } catch (e) {}
  }

  static Future<Map<String, dynamic>?> getPoint(String token, int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/place/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getAllPoints(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/place/all"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static void changePointStatus(String token, int id, bool newState) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/admin/place/$id/toggle"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"new_state": newState}),
      );
    } catch (e) {}
  }

  static Future<Null> deletePoint(String token, int id) async {
    try {
      await http.delete(
        Uri.parse("$baseUrl/admin/place/$id/delete"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return null;
    } catch (e) {
      return null;
    }
  }
}

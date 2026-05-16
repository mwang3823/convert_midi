import 'dart:convert';

class Utilities {
  static Map<String, dynamic> stringToJson(String raw) {
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

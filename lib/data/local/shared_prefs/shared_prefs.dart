import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  final SharedPreferences _prefs;
  SharedPrefs(this._prefs);

  String getString(String key, {String value = ''}) => _prefs.getString(key) ?? value;
  int    getInt   (String key, {int    value = 0})    => _prefs.getInt(key)    ?? value;
  bool   getBool  (String key, {bool   value = false}) => _prefs.getBool(key)  ?? value;
  double getDouble(String key, {double value = 0.0})  => _prefs.getDouble(key) ?? value;

  setString(String key, String? value) => _prefs.setString(key, value ?? '');
  setInt   (String key, int?    value) => _prefs.setInt(key, value ?? 0);
  setBool  (String key, bool?   value) => _prefs.setBool(key, value ?? false);
  setDouble(String key, double? value) => _prefs.setDouble(key, value ?? 0.0);
  remove   (String key) => _prefs.remove(key);
  clearAll ()           => _prefs.clear();
}

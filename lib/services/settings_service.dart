import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _wolIpKey = 'wol_ip';
  static const String _wolMacKey = 'wol_mac';
  static const String _defaultIp = '192.168.1.100';
  static const String _defaultMac = '00:00:00:00:00:00';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<String> getWolIp() async {
    final prefs = await _prefs;
    return prefs.getString(_wolIpKey) ?? _defaultIp;
  }

  static Future<void> setWolIp(String ip) async {
    final prefs = await _prefs;
    await prefs.setString(_wolIpKey, ip);
  }

  static Future<String> getWolMac() async {
    final prefs = await _prefs;
    return prefs.getString(_wolMacKey) ?? _defaultMac;
  }

  static Future<void> setWolMac(String mac) async {
    final prefs = await _prefs;
    await prefs.setString(_wolMacKey, mac);
  }
}

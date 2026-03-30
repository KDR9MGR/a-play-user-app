import 'package:shared_preferences/shared_preferences.dart';

class BlockService {
  static const String _prefsKey = 'blockedUsers_v1';

  static Future<List<String>> getBlockedUserIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey) ?? <String>[];
  }

  static Future<void> blockUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? <String>[];
    if (!current.contains(userId)) {
      current.add(userId);
      await prefs.setStringList(_prefsKey, current);
    }
  }

  static Future<void> unblockUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? <String>[];
    current.remove(userId);
    await prefs.setStringList(_prefsKey, current);
  }
}
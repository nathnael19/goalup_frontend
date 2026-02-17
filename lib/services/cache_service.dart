import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _keyPrefix = 'cache_';

  // Singleton pattern
  static final CacheService _instance = CacheService._internal();

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  /// Saves data to cache with an optional TTL (Time To Live).
  /// [key] should be unique (e.g., API URL).
  /// [value] must be JSON-encodable (Map, List, String, etc.).
  Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheEntry = {
      'data': value,
      'expiry': ttl != null ? DateTime.now().add(ttl).toIso8601String() : null,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString('$_keyPrefix$key', json.encode(cacheEntry));
  }

  /// Retrieves data from cache.
  /// Returns null if not found or expired.
  Future<dynamic> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_keyPrefix$key');
    if (jsonString == null) return null;

    try {
      final cacheEntry = json.decode(jsonString);
      final expiryString = cacheEntry['expiry'];

      if (expiryString != null) {
        final expiry = DateTime.parse(expiryString);
        if (DateTime.now().isAfter(expiry)) {
          // Expired, efficiently remove it in background
          prefs.remove('$_keyPrefix$key');
          return null;
        }
      }
      return cacheEntry['data'];
    } catch (e) {
      // Corrupt cache
      prefs.remove('$_keyPrefix$key');
      return null;
    }
  }

  /// Retrieves data from cache even if it is expired (useful for offline fallback).
  Future<dynamic> getStale(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_keyPrefix$key');
    if (jsonString == null) return null;

    try {
      final cacheEntry = json.decode(jsonString);
      return cacheEntry['data'];
    } catch (e) {
      return null;
    }
  }

  /// Removes a specific key from cache.
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$key');
  }

  /// Clears all cached data managed by this service.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .toList();
    for (var key in keys) {
      await prefs.remove(key);
    }
  }
}

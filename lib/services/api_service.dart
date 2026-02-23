import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/match.dart';
import '../models/team.dart';
import '../models/tournament.dart';

import 'cache_service.dart';

class ApiService {
  final CacheService _cacheService = CacheService();

  static String get baseUrl {
    if (kIsWeb) {
      return 'https://goalupbackend.webcode.codes/api/v1';
    }
    if (kDebugMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'https://goalupbackend.webcode.codes/api/v1';
      }
      return 'http://localhost:8000/api/v1';
    }
    return 'https://goalupbackend.webcode.codes/api/v1';
  }

  Future<dynamic> _getWithCache(
    String endpoint, {
    bool forceRefresh = false,
    Duration? ttl,
  }) async {
    final url = '$baseUrl$endpoint';

    if (!forceRefresh) {
      final cached = await _cacheService.get(url);
      if (cached != null) return cached;
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cacheService.set(url, data, ttl: ttl);
        return data;
      } else {
        throw Exception('Failed to load $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      // Offline fallback
      final stale = await _cacheService.getStale(url);
      if (stale != null) return stale;
      rethrow;
    }
  }

  /// Retrieves data from cache without performing a network request.
  /// Useful for "instant-load" UI patterns.
  Future<dynamic> getCached(String endpoint) async {
    final url = '$baseUrl$endpoint';
    return await _cacheService.getStale(url);
  }

  // --- Tournaments ---
  Future<Tournament> getTournament(
    String id, {
    bool forceRefresh = false,
  }) async {
    final data = await _getWithCache(
      '/tournaments/$id',
      forceRefresh: forceRefresh,
      ttl: const Duration(hours: 1),
    );
    return Tournament.fromJson(data);
  }

  Future<List<Tournament>> getCompetitionSeasons(
    String competitionId, {
    bool forceRefresh = false,
  }) async {
    final data = await _getWithCache(
      '/tournaments/',
      forceRefresh: forceRefresh,
      ttl: const Duration(hours: 1),
    );
    final allTournaments = (data as List)
        .map((json) => Tournament.fromJson(json))
        .toList();
    return allTournaments
        .where((t) => t.competitionId == competitionId)
        .toList();
  }

  // --- Matches ---
  Future<List<Match>> getMatches({bool forceRefresh = false}) async {
    final data = await _getWithCache(
      '/matches/',
      forceRefresh: forceRefresh,
      ttl: const Duration(minutes: 1),
    );
    return (data as List).map((json) => Match.fromJson(json)).toList();
  }

  Future<Match> getMatch(String id, {bool forceRefresh = false}) async {
    final data = await _getWithCache(
      '/matches/$id',
      forceRefresh: forceRefresh,
      ttl: const Duration(minutes: 1),
    );
    return Match.fromJson(data);
  }

  // --- Standings ---
  Future<List<dynamic>> getStandings({bool forceRefresh = false}) async {
    final data = await _getWithCache(
      '/standings/',
      forceRefresh: forceRefresh,
      ttl: const Duration(hours: 1),
    );
    return data;
  }

  Future<Map<String, dynamic>> getTournamentStandings(
    String tournamentId, {
    bool forceRefresh = false,
  }) async {
    final data = await _getWithCache(
      '/standings/$tournamentId',
      forceRefresh: forceRefresh,
      ttl: const Duration(hours: 1),
    );
    return data;
  }

  // --- Teams ---
  Future<List<Team>> getTeams({bool forceRefresh = false}) async {
    final data = await _getWithCache(
      '/teams/',
      forceRefresh: forceRefresh,
      ttl: const Duration(days: 1),
    );
    return (data as List).map((json) => Team.fromJson(json)).toList();
  }

  Future<Team> getTeam(String id, {bool forceRefresh = false}) async {
    final data = await _getWithCache(
      '/teams/$id',
      forceRefresh: forceRefresh,
      ttl: const Duration(hours: 6),
    );
    return Team.fromJson(data);
  }

  // --- Players ---
  Future<List<dynamic>> getPlayers({bool forceRefresh = false}) async {
    final data = await _getWithCache(
      '/players/',
      forceRefresh: forceRefresh,
      ttl: const Duration(days: 1),
    );
    return data;
  }

  // --- News ---
  Future<List<dynamic>> getNews({
    String? category,
    bool forceRefresh = false,
  }) async {
    final endpoint = category != null && category != 'All'
        ? '/news/?category=$category'
        : '/news/';
    final data = await _getWithCache(
      endpoint,
      forceRefresh: forceRefresh,
      ttl: const Duration(minutes: 30),
    );
    return data;
  }

  // --- Notifications ---
  Future<List<dynamic>> getNotifications({bool forceRefresh = false}) async {
    final data = await _getWithCache(
      '/notifications/',
      forceRefresh: forceRefresh,
      ttl: const Duration(seconds: 30),
    );
    return data;
  }

  Future<void> markNotificationAsRead(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'is_read': true}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
    // Invalidate notifications cache?
    // Ideally yes, but simpler to let it expire in 30s.
    // Or remove key:
    _cacheService.remove('$baseUrl/notifications/');
  }

  Future<void> markAllNotificationsAsRead() async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/read-all'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
    _cacheService.remove('$baseUrl/notifications/');
  }

  static String getImageFullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final serverRoot = baseUrl.replaceAll('/api/v1', '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$serverRoot$cleanPath';
  }
}

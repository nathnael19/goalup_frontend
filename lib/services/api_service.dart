import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/match.dart';
import '../models/team.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 is the special IP for Android Emulator to access host machine
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  // --- Matches ---
  Future<List<Match>> getMatches() async {
    final response = await http.get(Uri.parse('$baseUrl/matches/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<Match> getMatch(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/matches/$id'));
    if (response.statusCode == 200) {
      return Match.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load match $id');
    }
  }

  // --- Standings ---
  Future<List<dynamic>> getStandings() async {
    // The current backend returns a List[GroupedTournamentStandings]
    final response = await http.get(Uri.parse('$baseUrl/standings/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load standings');
    }
  }

  Future<Map<String, dynamic>> getTournamentStandings(
    String tournamentId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/standings/$tournamentId'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load standings for tournament $tournamentId');
    }
  }

  // --- Teams ---
  Future<List<Team>> getTeams() async {
    final response = await http.get(Uri.parse('$baseUrl/teams/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Team.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load teams');
    }
  }

  Future<Team> getTeam(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/teams/$id'));
    if (response.statusCode == 200) {
      return Team.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load team $id');
    }
  }
}

import 'team.dart';
import 'tournament.dart';

enum MatchStatus { scheduled, live, finished }

class Match {
  final String id;
  final String tournamentId;
  final String teamAId;
  final String teamBId;
  final int scoreA;
  final int scoreB;
  final MatchStatus status;
  final DateTime startTime;

  // Enriched data
  final Tournament? tournament;
  final Team? teamA;
  final Team? teamB;

  Match({
    required this.id,
    required this.tournamentId,
    required this.teamAId,
    required this.teamBId,
    required this.scoreA,
    required this.scoreB,
    required this.status,
    required this.startTime,
    this.tournament,
    this.teamA,
    this.teamB,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      tournamentId: json['tournament_id'],
      teamAId: json['team_a_id'],
      teamBId: json['team_b_id'],
      scoreA: json['score_a'] ?? 0,
      scoreB: json['score_b'] ?? 0,
      status: MatchStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MatchStatus.scheduled,
      ),
      startTime: DateTime.parse(json['start_time']),
      tournament: json['tournament'] != null
          ? Tournament.fromJson(json['tournament'])
          : null,
      teamA: json['team_a'] != null ? Team.fromJson(json['team_a']) : null,
      teamB: json['team_b'] != null ? Team.fromJson(json['team_b']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'team_a_id': teamAId,
      'team_b_id': teamBId,
      'score_a': scoreA,
      'score_b': scoreB,
      'status': status.name,
      'start_time': startTime.toIso8601String(),
    };
  }
}

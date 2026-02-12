import 'team.dart';
import 'tournament.dart';
import 'event.dart';

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
  final String? venue;

  // Enriched data
  final Tournament? tournament;
  final Team? teamA;
  final Team? teamB;
  final List<Goal>? goals;
  final List<Card>? cards;
  final List<Substitution>? substitutions;
  final List<Lineup>? lineups;

  Match({
    required this.id,
    required this.tournamentId,
    required this.teamAId,
    required this.teamBId,
    required this.scoreA,
    required this.scoreB,
    required this.status,
    required this.startTime,
    this.venue,
    this.tournament,
    this.teamA,
    this.teamB,
    this.goals,
    this.cards,
    this.substitutions,
    this.lineups,
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
      venue: json['venue'],
      tournament: json['tournament'] != null
          ? Tournament.fromJson(json['tournament'])
          : null,
      teamA: json['team_a'] != null ? Team.fromJson(json['team_a']) : null,
      teamB: json['team_b'] != null ? Team.fromJson(json['team_b']) : null,
      goals: json['goals'] != null
          ? (json['goals'] as List).map((e) => Goal.fromJson(e)).toList()
          : null,
      cards: json['cards'] != null
          ? (json['cards'] as List).map((e) => Card.fromJson(e)).toList()
          : null,
      substitutions: json['substitutions'] != null
          ? (json['substitutions'] as List)
                .map((e) => Substitution.fromJson(e))
                .toList()
          : null,
      lineups: json['lineups'] != null
          ? (json['lineups'] as List).map((e) => Lineup.fromJson(e)).toList()
          : null,
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

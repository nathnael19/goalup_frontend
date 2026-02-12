import 'player.dart';
import 'match.dart';
import 'standing.dart';
import 'tournament.dart';

class Team {
  final String id;
  final String name;
  final String? batch;
  final String? logoUrl;
  final String? color;
  final Map<String, List<Player>>? roster;
  final List<Match>? matches;
  final List<Standing>? standings;
  final Tournament? tournament;

  Team({
    required this.id,
    required this.name,
    this.batch,
    this.logoUrl,
    this.color,
    this.roster,
    this.matches,
    this.standings,
    this.tournament,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    Map<String, List<Player>>? roster;
    if (json['roster'] != null) {
      roster = {};
      (json['roster'] as Map<String, dynamic>).forEach((key, value) {
        roster![key] = (value as List).map((p) => Player.fromJson(p)).toList();
      });
    }

    return Team(
      id: json['id'],
      name: json['name'],
      batch: json['batch'],
      logoUrl: json['logo_url'],
      color: json['color'],
      roster: roster,
      matches: json['matches'] != null
          ? (json['matches'] as List).map((m) => Match.fromJson(m)).toList()
          : null,
      standings: json['standings'] != null
          ? (json['standings'] as List)
                .map((s) => Standing.fromJson(s))
                .toList()
          : null,
      tournament: json['tournament'] != null
          ? Tournament.fromJson(json['tournament'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'batch': batch, 'logo_url': logoUrl};
  }
}

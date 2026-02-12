import 'player.dart';

class Goal {
  final String id;
  final String matchId;
  final String teamId;
  final String? playerId;
  final String? assistantId;
  final int minute;
  final bool isOwnGoal;

  // Enriched
  final Player? player;
  final Player? assistant;

  Goal({
    required this.id,
    required this.matchId,
    required this.teamId,
    this.playerId,
    this.assistantId,
    required this.minute,
    required this.isOwnGoal,
    this.player,
    this.assistant,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      matchId: json['match_id'],
      teamId: json['team_id'],
      playerId: json['player_id'],
      assistantId: json['assistant_id'],
      minute: json['minute'],
      isOwnGoal: json['is_own_goal'] ?? false,
      player: json['player'] != null ? Player.fromJson(json['player']) : null,
      assistant: json['assistant'] != null
          ? Player.fromJson(json['assistant'])
          : null,
    );
  }
}

class Card {
  final String id;
  final String matchId;
  final String teamId;
  final String playerId;
  final int minute;
  final String type; // yellow, red

  // Enriched
  final Player? player;

  Card({
    required this.id,
    required this.matchId,
    required this.teamId,
    required this.playerId,
    required this.minute,
    required this.type,
    this.player,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'],
      matchId: json['match_id'],
      teamId: json['team_id'],
      playerId: json['player_id'],
      minute: json['minute'],
      type: json['type'],
      player: json['player'] != null ? Player.fromJson(json['player']) : null,
    );
  }
}

class Substitution {
  final String id;
  final String matchId;
  final String teamId;
  final String playerInId;
  final String playerOutId;
  final int minute;

  // Enriched
  final Player? playerIn;
  final Player? playerOut;

  Substitution({
    required this.id,
    required this.matchId,
    required this.teamId,
    required this.playerInId,
    required this.playerOutId,
    required this.minute,
    this.playerIn,
    this.playerOut,
  });

  factory Substitution.fromJson(Map<String, dynamic> json) {
    return Substitution(
      id: json['id'],
      matchId: json['match_id'],
      teamId: json['team_id'],
      playerInId: json['player_in_id'],
      playerOutId: json['player_out_id'],
      minute: json['minute'],
      playerIn: json['player_in'] != null
          ? Player.fromJson(json['player_in'])
          : null,
      playerOut: json['player_out'] != null
          ? Player.fromJson(json['player_out'])
          : null,
    );
  }
}

class Lineup {
  final String id;
  final String matchId;
  final String teamId;
  final String playerId;
  final bool isStarting;

  // Enriched
  final Player? player;

  Lineup({
    required this.id,
    required this.matchId,
    required this.teamId,
    required this.playerId,
    required this.isStarting,
    this.player,
  });

  factory Lineup.fromJson(Map<String, dynamic> json) {
    return Lineup(
      id: json['id'],
      matchId: json['match_id'],
      teamId: json['team_id'],
      playerId: json['player_id'],
      isStarting: json['is_starting'] ?? true,
      player: json['player'] != null ? Player.fromJson(json['player']) : null,
    );
  }
}

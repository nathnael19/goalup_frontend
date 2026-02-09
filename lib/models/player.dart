class Player {
  final String id;
  final String name;
  final String teamId;
  final int jerseyNumber;
  final String position;
  final int goals;
  final int yellowCards;
  final int redCards;

  Player({
    required this.id,
    required this.name,
    required this.teamId,
    required this.jerseyNumber,
    required this.position,
    this.goals = 0,
    this.yellowCards = 0,
    this.redCards = 0,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      teamId: json['team_id'],
      jerseyNumber: json['jersey_number'],
      position: json['position'],
      goals: json['goals'] ?? 0,
      yellowCards: json['yellow_cards'] ?? 0,
      redCards: json['red_cards'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'team_id': teamId,
      'jersey_number': jerseyNumber,
      'position': position,
      'goals': goals,
      'yellow_cards': yellowCards,
      'red_cards': redCards,
    };
  }
}

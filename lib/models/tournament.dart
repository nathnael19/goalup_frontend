class Competition {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  Competition({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
    };
  }
}

class Tournament {
  final String id;
  final String name;
  final int year;
  final String type;
  final String? competitionId;
  final Competition? competition;

  Tournament({
    required this.id,
    required this.name,
    required this.year,
    required this.type,
    this.competitionId,
    this.competition,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      year: json['year'],
      type: json['type'],
      competitionId: json['competition_id'],
      competition: json['competition'] != null
          ? Competition.fromJson(json['competition'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'year': year, 'type': type};
  }
}

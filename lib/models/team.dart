class Team {
  final String id;
  final String name;
  final String batch;
  final String? logoUrl;

  Team({
    required this.id,
    required this.name,
    required this.batch,
    this.logoUrl,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      batch: json['batch'],
      logoUrl: json['logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'batch': batch, 'logo_url': logoUrl};
  }
}

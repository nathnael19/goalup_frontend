class Tournament {
  final String id;
  final String name;
  final int year;
  final String type;

  Tournament({
    required this.id,
    required this.name,
    required this.year,
    required this.type,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      year: json['year'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'year': year, 'type': type};
  }
}

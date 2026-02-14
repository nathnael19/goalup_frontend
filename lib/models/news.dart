class News {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String description;
  final String? imageUrl;
  final String? content;
  final String reporterName;

  News({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.description,
    this.imageUrl,
    required this.reporterName,
    this.content,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      date: DateTime.parse(json['created_at']),
      description: json['content'] != null && json['content'].length > 100
          ? json['content'].substring(0, 100) + '...'
          : json['content'] ?? '',
      content: json['content'],
      imageUrl: json['image_url'],
      reporterName:
          'GoalUp Reporter', // Reporter name not in backend NewsRead yet
    );
  }
}

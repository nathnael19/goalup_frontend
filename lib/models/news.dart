class News {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String description;
  final String imageUrl;
  final String? content;

  News({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.description,
    required this.imageUrl,
    this.content,
  });
}

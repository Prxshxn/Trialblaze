// models/blog.dart
class Blog {
  final String id;
  final String title;
  final String imageUrl;
  final String excerpt;
  final String content;
  final String readTime;
  final DateTime publishDate;
  final String authorName;

  const Blog({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.excerpt,
    required this.content,
    required this.readTime,
    required this.publishDate,
    required this.authorName,
  });
}

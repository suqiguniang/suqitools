class WebCardModel {
  final String id;
  final String title;
  final String description;
  final String url;
  final DateTime createdAt;

  WebCardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WebCardModel.fromJson(Map<String, dynamic> json) {
    return WebCardModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

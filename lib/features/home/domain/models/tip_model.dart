class TipModel {
  final String content;
  final String? category;
  final String language;

  TipModel({
    required this.content,
    this.category,
    required this.language,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      content: json['content'] ?? '',
      category: json['category'],
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'category': category,
      'language': language,
    };
  }
}

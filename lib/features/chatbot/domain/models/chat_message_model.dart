class ChatMessageModel {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final List<String>? navigations;
  final String? language;
  final String? sourceLanguage;
  final String? error;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isUser,
    this.navigations,
    this.language,
    this.sourceLanguage,
    this.error,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] as String),
      isUser: map['sender'] == 'User',
      navigations: List<String>.from(map['navigations'] ?? []),
      language: map['language'],
      sourceLanguage: map['sourceLanguage'],
      error: map['error'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'sender': isUser ? 'User' : 'Machine',
      'navigations': navigations,
      'language': language,
      'sourceLanguage': sourceLanguage,
      'error': error,
    };
  }
}

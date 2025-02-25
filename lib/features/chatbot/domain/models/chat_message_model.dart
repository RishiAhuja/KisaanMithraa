class ChatMessageModel {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final String? error;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isUser,
    this.error,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] as String),
      isUser: map['sender'] == 'User',
      error: map['error'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'sender': isUser ? 'User' : 'Machine',
      'error': error,
    };
  }
}

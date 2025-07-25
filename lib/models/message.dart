class Message {
  String content;
  String? sessionId;
  String? extraSystemPrompt;
  final String id;
  final String sender;

  Message({
    required this.id,
    required this.content,
    required this.sender,
    this.sessionId,
    this.extraSystemPrompt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'sender': sender,
    'sessionId': sessionId,
    'extraSystemPrompt': extraSystemPrompt,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    content: json['text'] as String,
    sender: json['sender'] as String,
    sessionId: json['sessionId'] as String? ?? '',
    extraSystemPrompt: json['extraSystemPrompt'] as String? ?? '',
  );
}

class ChatSession {
  final String id;
  final List<Message> messages;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.messages,
    this.name = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'messages': messages.map((m) => m.toJson()).toList(),
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String,
    messages: (json['messages'] as List<dynamic>)
        .map((m) => Message.fromJson(m as Map<String, dynamic>))
        .toList(),
    name: json['name'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class RevisedMessage {
  final String content;

  RevisedMessage({required this.content});

  Map<String, dynamic> toJson() => {'content': content};

  factory RevisedMessage.fromJson(Map<String, dynamic> json) =>
      RevisedMessage(content: json['text'] as String);
}

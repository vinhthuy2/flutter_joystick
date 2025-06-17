class MessageTemplate {
  final String id;
  final String text;
  final String category;
  final DateTime createdAt;
  final DateTime? lastUsed;

  MessageTemplate({
    required this.id,
    required this.text,
    required this.category,
    required this.createdAt,
    this.lastUsed,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'lastUsed': lastUsed?.toIso8601String(),
  };

  factory MessageTemplate.fromJson(Map<String, dynamic> json) =>
      MessageTemplate(
        id: json['id'] as String,
        text: json['text'] as String,
        category: json['category'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUsed: json['lastUsed'] != null
            ? DateTime.parse(json['lastUsed'] as String)
            : null,
      );
}

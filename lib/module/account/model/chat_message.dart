class ChatMessage {
  final String? id;
  final String? userId;
  final String messageContent;
  final String messageType;
  final DateTime? createdAt;

  ChatMessage({
    this.id,
    this.userId,
    required this.messageContent,
    required this.messageType,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id']?.toString(),
      userId: json['userId']?.toString(),
      messageContent: json['content']?.toString() ?? json['messageContent']?.toString() ?? '',
      messageType: json['type']?.toString() ?? json['messageType']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'content': messageContent,
    'type': messageType,
    'createdAt': createdAt?.toIso8601String(),
  };
}
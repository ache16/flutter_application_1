class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  
  // 关联信息
  final String? senderName;
  final String? senderAvatar;
  final String? receiverName;
  final String? receiverAvatar;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = 'text',
    this.isRead = false,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
    this.receiverName,
    this.receiverAvatar,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      type: json['type'] ?? 'text',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      receiverName: json['receiver_name'],
      receiverAvatar: json['receiver_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'type': type,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isVoice => type == 'voice';
}

class Friend {
  final int id;
  final String username;
  final String nickname;
  final String? avatar;
  final String? bio;
  final DateTime? friendshipDate;
  final bool isOnline;

  Friend({
    required this.id,
    required this.username,
    required this.nickname,
    this.avatar,
    this.bio,
    this.friendshipDate,
    this.isOnline = false,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'] ?? json['username'],
      avatar: json['avatar'],
      bio: json['bio'],
      friendshipDate: json['friendship_date'] != null 
          ? DateTime.parse(json['friendship_date']) 
          : null,
      isOnline: json['is_online'] == true,
    );
  }
}

class FriendRequest {
  final int requestId;
  final int userId;
  final String username;
  final String nickname;
  final String? avatar;
  final DateTime createdAt;

  FriendRequest({
    required this.requestId,
    required this.userId,
    required this.username,
    required this.nickname,
    this.avatar,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      requestId: json['request_id'],
      userId: json['id'],
      username: json['username'],
      nickname: json['nickname'] ?? json['username'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

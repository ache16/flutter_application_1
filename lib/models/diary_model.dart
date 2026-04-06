class Diary {
  final int id;
  final int userId;
  final String title;
  final String content;
  final String? mood;
  final String? weather;
  final List<String>? images;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // 关联信息
  final String? authorName;
  final String? authorAvatar;

  Diary({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.mood,
    this.weather,
    this.images,
    this.isPrivate = true,
    required this.createdAt,
    this.updatedAt,
    this.authorName,
    this.authorAvatar,
  });

  factory Diary.fromJson(Map<String, dynamic> json) {
    List<String>? imageList;
    if (json['images'] != null) {
      if (json['images'] is String) {
        // 处理 JSON 字符串
        try {
          // 简单处理，假设是逗号分隔或 JSON 数组字符串
          final str = json['images'] as String;
          if (str.startsWith('[')) {
            // JSON 数组
            imageList = (json['images'] as List).cast<String>();
          } else {
            imageList = [str];
          }
        } catch (e) {
          imageList = [];
        }
      } else if (json['images'] is List) {
        imageList = (json['images'] as List).cast<String>();
      }
    }

    return Diary(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      mood: json['mood'],
      weather: json['weather'],
      images: imageList,
      isPrivate: json['is_private'] == 1 || json['is_private'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      authorName: json['author_name'],
      authorAvatar: json['author_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'mood': mood,
      'weather': weather,
      'images': images,
      'is_private': isPrivate ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Diary copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? mood,
    String? weather,
    List<String>? images,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorAvatar,
  }) {
    return Diary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      weather: weather ?? this.weather,
      images: images ?? this.images,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
    );
  }

  // 获取心情图标
  String? get moodEmoji {
    final moodMap = {
      'happy': '😊',
      'sad': '😢',
      'angry': '😠',
      'anxious': '😰',
      'love': '😍',
      'tired': '😴',
      'thinking': '🤔',
      'cool': '😎',
      'excited': '🤩',
      'calm': '😌',
    };
    return moodMap[mood] ?? mood;
  }

  // 获取天气图标
  String? get weatherEmoji {
    final weatherMap = {
      'sunny': '☀️',
      'cloudy': '☁️',
      'rainy': '🌧️',
      'stormy': '⛈️',
      'snowy': '🌨️',
      'partly_cloudy': '🌤️',
      'windy': '💨',
      'foggy': '🌫️',
    };
    return weatherMap[weather] ?? weather;
  }
}

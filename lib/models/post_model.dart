class Post {
  final String id;
  final String title;
  final String body;
  final int totalVote;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.totalVote,
    required this.createdAt,
  });

  Post copyWith({
    String? id,
    String? title,
    String? body,
    int? totalVote,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      totalVote: totalVote ?? this.totalVote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'totalVote': totalVote,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      totalVote: map['totalVote'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}

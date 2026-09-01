import 'package:feed_domain/feed_domain.dart';

class FeedItemDto {
  const FeedItemDto({required this.id, required this.title, this.done = false});

  final String id;
  final String title;
  final bool done;

  factory FeedItemDto.fromJson(Map<String, dynamic> json) {
    return FeedItemDto(
      id: json['id'] as String,
      title: json['title'] as String,
      done: json['done'] as bool? ?? false,
    );
  }

  FeedItem toEntity() => FeedItem(id: id, title: title, done: done);

  static List<FeedItemDto> listFromJson(Object json) {
    final map = json as Map<String, dynamic>;
    return [
      for (final raw in map['items'] as List<dynamic>)
        FeedItemDto.fromJson(raw as Map<String, dynamic>),
    ];
  }
}

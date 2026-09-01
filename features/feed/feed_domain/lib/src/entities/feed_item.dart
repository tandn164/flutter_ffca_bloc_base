class FeedItem {
  const FeedItem({
    required this.id,
    required this.title,
    this.done = false,
  });

  final String id;
  final String title;
  final bool done;

  FeedItem copyWith({String? id, String? title, bool? done}) {
    return FeedItem(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FeedItem && other.id == id && other.title == title && other.done == done;

  @override
  int get hashCode => Object.hash(id, title, done);
}

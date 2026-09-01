import 'feed_item.dart';

class FeedChunk {
  const FeedChunk({required this.items, required this.hasMore});

  final List<FeedItem> items;
  final bool hasMore;
}

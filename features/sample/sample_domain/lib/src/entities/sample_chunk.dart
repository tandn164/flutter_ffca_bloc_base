import 'sample_item.dart';

class SampleChunk {
  const SampleChunk({required this.items, required this.hasMore});

  final List<SampleItem> items;
  final bool hasMore;
}

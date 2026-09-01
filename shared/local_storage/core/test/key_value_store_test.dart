import 'package:local_storage/local_storage.dart';
import 'package:test/test.dart';

void main() {
  test('memory store reads, writes, and removes values', () async {
    final store = MemoryKeyValueStore();
    await store.writeString('key', 'value');
    expect(await store.readString('key'), 'value');
    await store.remove('key');
    expect(await store.readString('key'), isNull);
  });
}

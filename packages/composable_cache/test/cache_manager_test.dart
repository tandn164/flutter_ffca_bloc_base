import 'package:composable_cache/composable_cache.dart';
import 'package:test/test.dart';

void main() {
  group('CacheManager', () {
    test('put and get within ttl', () async {
      final manager = CacheManager(store: InMemoryCacheStore());

      await manager.put('user', 'alice', ttl: const Duration(minutes: 1));
      expect(await manager.get<String>('user'), 'alice');
    });

    test('expired entries return null', () async {
      final manager = CacheManager(store: InMemoryCacheStore());

      await manager.put('user', 'alice', ttl: Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(await manager.get<String>('user'), isNull);
    });

    test('invalidate removes entry', () async {
      final manager = CacheManager(store: InMemoryCacheStore());

      await manager.put('user', 'alice');
      await manager.invalidate('user');
      expect(await manager.get<String>('user'), isNull);
    });
  });
}

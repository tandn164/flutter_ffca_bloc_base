# composable_cache

> Trong ComposableCore monorepo: depend `composable_core` + `composable_network`.  
> Bật qua `packages.cache.enabled` trong `composable_config.json`.

## 1. Vấn đề giải quyết

GET API chậm / lặp lại; cần cache TTL và invalidate mà không trộn logic vào repository.

## 2. Kiến thức cốt lõi

- **Cache key strategy:** `{method}:{path}:{queryHash}` hoặc domain-specific key.
- **TTL:** mỗi entry có `expiresAt` — đọc quá hạn = cache miss.
- **Stale-while-revalidate:** trả cache ngay + fetch background (implement ở repository).
- **Độc lập offline:** cache có thể bật mà không cần offline queue.

## 3. Kiến trúc trong ComposableCore

| Thành phần | Trách nhiệm |
|------------|-------------|
| `CacheStore` | Abstract storage (in-memory / Hive) |
| `InMemoryCacheStore` | Default engine |
| `CacheManager` | get / put / invalidate / clear |
| `ComposableCacheModule` | DI theo `cache.engine` |

## 4. Config & flags

```json
"cache": {
  "enabled": true,
  "engine": "hive"
}
```

Hiện tại `hive` fallback về in-memory cho đến khi Hive dependency được thêm.

## 5. Tự implement ở codebase khác

1. Interface `CacheStore` + impl (memory / Hive / Isar).
2. `CacheManager` với TTL trên mỗi `put`.
3. Repository: cache-first read → network → update cache.

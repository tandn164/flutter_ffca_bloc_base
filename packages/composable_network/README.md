# composable_network

> Trong ComposableCore monorepo: depend `composable_core` + luôn bật qua `ComposableNetworkModule`.  
> README này để **nắm kiến thức cốt lõi** — tự implement thủ công ở codebase khác nếu cần.

## 1. Vấn đề giải quyết

API response JSON lỗi format gây crash; connectivity check rải rác; không có contract thống nhất cho retry/cache flags trên từng request.

## 2. Kiến thức cốt lõi

- **Safe decode:** parse JSON trong `try/catch`, trả `ApiResult<T>` thay vì throw — app quyết định map sang `Failure`.
- **Connectivity stream:** một `ConnectivityService` broadcast online/offline — offline queue và UI banner chỉ subscribe.
- **ApiRequestConfig:** metadata per-request (`retryOnReconnect`, `cacheable`, `idempotent`) — interceptor đọc flag, không hard-code trong repository.

## 3. Kiến trúc trong ComposableCore

| Thành phần | Trách nhiệm |
|------------|-------------|
| `ConnectivityService` | Stream + `isConnected` |
| `NetworkInfo` | Facade cho repository layer |
| `SafeResponseParser` | Decode an toàn |
| `ApiRequestConfig` | Policy flags |
| `ComposableNetworkModule` | DI registration |

## 4. Config & flags

Core package — **không có flag** trong `composable_config.json`. Luôn có trong pubspec.

## 5. Tự implement ở codebase khác

1. Tạo parser wrapper trả `Result<T, Error>` thay vì throw khi JSON sai.
2. Expose `Stream<bool>` connectivity từ `connectivity_plus` hoặc `internet_connection_checker`.
3. Gắn request metadata (annotation hoặc `RequestOptions.extra`) cho retry/cache.

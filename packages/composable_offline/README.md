# composable_offline

> Trong ComposableCore monorepo: depend `composable_core` + `composable_network`.  
> Bật qua `packages.offline.enabled` trong `composable_config.json`.

## 1. Vấn đề giải quyết

Request POST/PUT fail giữa chừng khi mất mạng — mất dữ liệu, user phải submit lại.

## 2. Kiến thức cốt lõi

- **Queue on disconnect:** request có `retryOnReconnect: true` được persist vào queue khi offline.
- **Flush on reconnect:** subscribe `ConnectivityService.onConnectivityChanged` → gọi `flush()` khi online.
- **Idempotency:** chỉ retry request đánh dấu `idempotent: true` (hoặc GET) để tránh duplicate side-effect.

## 3. Kiến trúc trong ComposableCore

| Thành phần | Trách nhiệm |
|------------|-------------|
| `OfflineQueueManager` | Enqueue, flush, max size |
| `OfflineRequest` | Serialized request snapshot |
| `ComposableOfflineModule` | DI + auto-flush bootstrap |

## 4. Config & flags

```json
"offline": {
  "enabled": true,
  "retryOnReconnect": true
}
```

`enabled: false` → package không có trong pubspec, không register DI.

## 5. Tự implement ở codebase khác

1. Persist queue (SQLite / SharedPreferences / Hive).
2. Listen connectivity stream.
3. Replay HTTP với cùng method/body/headers khi online.
4. Wire executor thật (Chopper/Dio) trong app bootstrap — package chỉ quản lý queue.

# composable_core

**Vai trò:** Nền tảng bắt buộc của ComposableCore — config, bootstrap, module contract.

## Quan hệ với các package khác

Mọi package trong monorepo (`composable_network`, `composable_offline`, `composable_auth`, …) **bắt buộc** depend `composable_core` và implement `ComposableCoreModule`.

```
composable_core  ←── composable_network
                 ←── composable_offline
                 ←── composable_auth
                 ←── …
```

## README package ≠ copy sang project khác

README của từng package **không** để copy code bỏ `composable_core`.

README mô tả **kiến thức cốt lõi** — khi làm **source code hoàn toàn khác** (không dùng ComposableCore), đọc README để **tự code thủ công** tính năng tương tự theo kiến trúc project đó.

## Nội dung package

| Export | Mục đích |
|--------|----------|
| `ComposableCoreConfig` | Parse `composable_config.json` |
| `ComposableCoreModule` | Contract bắt buộc cho mọi optional package |
| `ComposableCoreModuleDescriptor` | Generated registrars |
| `ComposableCoreBootstrap` | Thứ tự init: modules → app DI → bootstrap |

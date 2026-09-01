# App Connectivity

Provider-independent connectivity hints for networking, synchronization, and
app-wide offline UI.

## Purpose

`ConnectivityHint` reports only when the device is known to be offline. It does
not claim that an active network can reach your API. Every transport call must
still handle timeouts, DNS failures, and connection loss.

## Installation

```yaml
dependencies:
  app_connectivity:
    path: ../../shared/connectivity
```

## Quick start

Register one implementation in the app composition root and share it with the
API client, offline synchronizer, and app overlay.

```dart
final connectivity = MyConnectivityAdapter();
apiGateway = DataGateway(connectivity: connectivity, client: apiClient);
overlay = AppOverlayController(connectivity: connectivity);
```

Use `FakeConnectivity` in tests and demo applications:

```dart
final connectivity = FakeConnectivity()..setOffline(true);
```

## Important limitation

Do not block all HTTP calls merely because the hint says online or offline.
Connectivity changes race with real requests; transport failures remain the
source of truth.

## Testing

```bash
dart test shared/connectivity
```

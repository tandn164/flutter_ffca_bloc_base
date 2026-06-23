import '../connectivity/connectivity_service.dart';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService;

  final ConnectivityService _connectivityService;

  @override
  Future<bool> get isConnected => _connectivityService.isConnected;
}

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  bool _isConnected = true;
  Timer? _connectionCheckTimer;

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool get isConnected => _isConnected;

  void initialize() {
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    
    // Periodic connection check (every 30 seconds)
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkConnection();
    });
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((result) => 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet ||
      result == ConnectivityResult.vpn
    );

    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      _connectionStatusController.add(_isConnected);
      
      if (kDebugMode) {
        print('Network status changed: ${_isConnected ? "Connected" : "Disconnected"}');
      }
    }
  }

  void dispose() {
    _connectionCheckTimer?.cancel();
    _connectionStatusController.close();
  }
}
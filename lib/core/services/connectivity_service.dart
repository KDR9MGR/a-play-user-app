import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

class ConnectivityService {
  final _connectivity = Connectivity();
  final _internetChecker = InternetConnectionChecker.createInstance();
  final _connectivityController = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  ConnectivityService() {
    _init();
  }

  void _init() {
    // Listen to platform connectivity changes
    _connectivity.onConnectivityChanged.listen((results) async {
      // Take the first result if available, otherwise assume no connectivity
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      await _checkInternetConnection(result);
    });
    
    // Check connectivity on service creation
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    // Take the first result if available, otherwise assume no connectivity
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    await _checkInternetConnection(result);
  }

  Future<void> _checkInternetConnection(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      _connectivityController.add(false);
      return;
    }

    // Double check with actual internet connectivity
    final hasInternet = await _internetChecker.hasConnection;
    _connectivityController.add(hasInternet);
  }

  void dispose() {
    _connectivityController.close();
  }
} 
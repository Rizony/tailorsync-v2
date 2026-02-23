import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (results) {
      if (results.isEmpty) return true;
      if (results.contains(ConnectivityResult.none)) return true;
      return false; // has some connection
    },
    loading: () => false, // assume online while checking
    error: (err, stack) => false,
  );
});

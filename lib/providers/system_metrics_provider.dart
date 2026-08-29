import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/system/system_metrics_model.dart';
import '../core/system/system_metrics_service.dart';
import 'ssh_provider.dart';

final systemMetricsServiceProvider = Provider<SystemMetricsService>((ref) {
  return SystemMetricsService();
});

class SystemMetricsState {
  final bool isLoading;
  final SystemMetrics? metrics;
  final String? error;

  const SystemMetricsState({
    this.isLoading = false,
    this.metrics,
    this.error,
  });

  SystemMetricsState copyWith({
    bool? isLoading,
    SystemMetrics? metrics,
    String? error,
    bool clearError = false,
  }) {
    return SystemMetricsState(
      isLoading: isLoading ?? this.isLoading,
      metrics: metrics ?? this.metrics,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SystemMetricsNotifier extends Notifier<SystemMetricsState> {
  Timer? _pollingTimer;

  @override
  SystemMetricsState build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    // Listen to SSH connection state
    ref.listen(activeProfileProvider, (previous, next) {
      if (next != null) {
        fetchMetrics();
        _startPolling();
      } else {
        _stopPolling();
        state = const SystemMetricsState();
      }
    });

    // Initial fetch if already connected
    Future.microtask(() {
      final ssh = ref.read(sshServiceProvider);
      if (ssh.isConnected) {
        fetchMetrics();
        _startPolling();
      }
    });

    return const SystemMetricsState(isLoading: false);
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchMetrics(silent: true);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchMetrics({bool silent = false}) async {
    final ssh = ref.read(sshServiceProvider);
    if (!ssh.isConnected) {
      state = const SystemMetricsState(metrics: null);
      return;
    }

    if (!silent) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    final service = ref.read(systemMetricsServiceProvider);
    final res = await service.fetchMetrics(ssh);

    res.when(
      onSuccess: (data) {
        state = state.copyWith(
          isLoading: false,
          metrics: data,
          clearError: true,
        );
      },
      onFailure: (err) {
        state = state.copyWith(
          isLoading: false,
          error: err,
        );
      },
    );
  }
}

final systemMetricsProvider =
    NotifierProvider<SystemMetricsNotifier, SystemMetricsState>(
  SystemMetricsNotifier.new,
);

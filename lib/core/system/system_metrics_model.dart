import 'package:equatable/equatable.dart';

class SystemMetrics extends Equatable {
  final double cpuPercentage; // 0.0 to 1.0 (e.g. 0.25 = 25%)
  final double memoryPercentage; // 0.0 to 1.0
  final double diskPercentage; // 0.0 to 1.0

  final int usedMemMb;
  final int totalMemMb;

  final int usedDiskGb;
  final int totalDiskGb;

  final double loadAvg1m;
  final int cpuCores;

  final String uptime;
  final String hostname;
  final DateTime timestamp;

  const SystemMetrics({
    required this.cpuPercentage,
    required this.memoryPercentage,
    required this.diskPercentage,
    this.usedMemMb = 0,
    this.totalMemMb = 0,
    this.usedDiskGb = 0,
    this.totalDiskGb = 0,
    this.loadAvg1m = 0.0,
    this.cpuCores = 1,
    this.uptime = '',
    this.hostname = '',
    required this.timestamp,
  });

  factory SystemMetrics.empty() => SystemMetrics(
        cpuPercentage: 0.0,
        memoryPercentage: 0.0,
        diskPercentage: 0.0,
        timestamp: DateTime.now(),
      );

  String get formattedMemUsage {
    if (totalMemMb == 0) return '';
    if (totalMemMb > 1024) {
      final usedGb = (usedMemMb / 1024).toStringAsFixed(1);
      final totalGb = (totalMemMb / 1024).toStringAsFixed(1);
      return '$usedGb / $totalGb GB';
    }
    return '$usedMemMb / $totalMemMb MB';
  }

  String get formattedDiskUsage {
    if (totalDiskGb == 0) return '';
    return '$usedDiskGb / $totalDiskGb GB';
  }

  String get formattedLoad {
    return '${loadAvg1m.toStringAsFixed(2)} ($cpuCores cores)';
  }

  @override
  List<Object?> get props => [
        cpuPercentage,
        memoryPercentage,
        diskPercentage,
        usedMemMb,
        totalMemMb,
        usedDiskGb,
        totalDiskGb,
        loadAvg1m,
        cpuCores,
        uptime,
        hostname,
        timestamp,
      ];
}

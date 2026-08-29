import 'package:flutter_test/flutter_test.dart';
import 'package:setu/core/system/system_metrics_model.dart';
import 'package:setu/core/system/system_metrics_service.dart';

void main() {
  group('SystemMetricsModel Tests', () {
    test('Formatted strings calculate properly', () {
      final metrics = SystemMetrics(
        cpuPercentage: 0.25,
        memoryPercentage: 0.50,
        diskPercentage: 0.75,
        usedMemMb: 4096,
        totalMemMb: 16384,
        usedDiskGb: 120,
        totalDiskGb: 500,
        loadAvg1m: 0.85,
        cpuCores: 8,
        uptime: '3d 12h 45m',
        hostname: 'omarchy-box',
        timestamp: DateTime.now(),
      );

      expect(metrics.formattedMemUsage, equals('4.0 / 16.0 GB'));
      expect(metrics.formattedDiskUsage, equals('120 / 500 GB'));
      expect(metrics.formattedLoad, equals('0.85 (8 cores)'));
      expect(metrics.uptime, equals('3d 12h 45m'));
      expect(metrics.hostname, equals('omarchy-box'));
    });
  });

  group('SystemMetricsService Parsing Tests', () {
    late SystemMetricsService service;

    setUp(() {
      service = SystemMetricsService();
    });

    test('parseMetricsOutput parses Linux script output correctly', () {
      const sampleOutput = '''
3500 16000 22
120 480 25
35 1.40 4
5d 8h 22m
arch-omarchy
''';

      final metrics = service.parseMetricsOutput(sampleOutput);

      expect(metrics.usedMemMb, equals(3500));
      expect(metrics.totalMemMb, equals(16000));
      expect(metrics.memoryPercentage, closeTo(0.22, 0.01));

      expect(metrics.usedDiskGb, equals(120));
      expect(metrics.totalDiskGb, equals(480));
      expect(metrics.diskPercentage, closeTo(0.25, 0.01));

      expect(metrics.cpuPercentage, closeTo(0.35, 0.01));
      expect(metrics.loadAvg1m, closeTo(1.40, 0.01));
      expect(metrics.cpuCores, equals(4));

      expect(metrics.uptime, equals('5d 8h 22m'));
      expect(metrics.hostname, equals('arch-omarchy'));
    });

    test('parseMetricsOutput handles empty or malformed output gracefully', () {
      final metrics = service.parseMetricsOutput('');
      expect(metrics.cpuPercentage, equals(0.0));
      expect(metrics.memoryPercentage, equals(0.0));
      expect(metrics.diskPercentage, equals(0.0));
    });
  });
}

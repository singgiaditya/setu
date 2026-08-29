import '../ssh/ssh_service.dart';
import '../../shared/models/result.dart';
import 'system_metrics_model.dart';

class SystemMetricsService {
  static const String _metricsScript = r'''
sh -c '
awk "/^MemTotal:/{t=\$2} /^MemAvailable:/{a=\$2} END{u=t-a; printf \"%d %d %d\n\", u/1024, t/1024, (t>0? (u*100)/t : 0)}" /proc/meminfo
df -k / | awk "NR==2{u=\$3; t=\$2; printf \"%d %d %d\n\", u/1048576, t/1048576, (t>0? (u*100)/t : 0)}"
cores=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo 1)
load1=$(awk "{print \$1}" /proc/loadavg 2>/dev/null || echo 0)
cpu_pct=$(awk -v l="$load1" -v c="$cores" "BEGIN{p=(l/c)*100; if(p>100)p=100; printf \"%d\", p}")
echo "$cpu_pct $load1 $cores"
awk "{s=int(\$1); d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if(d>0) printf \"%dd %dh %dm\n\", d, h, m; else if(h>0) printf \"%dh %dm\n\", h, m; else printf \"%dm\n\", m}" /proc/uptime 2>/dev/null || uptime
hostname 2>/dev/null || uname -n
'
''';

  SystemMetrics parseMetricsOutput(String output) {
    final lines = output.trim().split('\n').map((l) => l.trim()).toList();
    if (lines.isEmpty) return SystemMetrics.empty();

    int usedMemMb = 0;
    int totalMemMb = 0;
    double memPercent = 0.0;

    int usedDiskGb = 0;
    int totalDiskGb = 0;
    double diskPercent = 0.0;

    double cpuPercent = 0.0;
    double load1m = 0.0;
    int cores = 1;

    String uptime = '';
    String hostname = '';

    // Line 0: Memory (used_mb total_mb percent)
    if (lines.isNotEmpty) {
      final parts = lines[0].split(' ');
      if (parts.length >= 3) {
        usedMemMb = int.tryParse(parts[0]) ?? 0;
        totalMemMb = int.tryParse(parts[1]) ?? 0;
        final rawPct = double.tryParse(parts[2]) ?? 0.0;
        memPercent = (rawPct / 100.0).clamp(0.0, 1.0);
      }
    }

    // Line 1: Disk (used_gb total_gb percent)
    if (lines.length > 1) {
      final parts = lines[1].split(' ');
      if (parts.length >= 3) {
        usedDiskGb = int.tryParse(parts[0]) ?? 0;
        totalDiskGb = int.tryParse(parts[1]) ?? 0;
        final rawPct = double.tryParse(parts[2]) ?? 0.0;
        diskPercent = (rawPct / 100.0).clamp(0.0, 1.0);
      }
    }

    // Line 2: CPU & Load (cpu_pct load1 cores)
    if (lines.length > 2) {
      final parts = lines[2].split(' ');
      if (parts.length >= 3) {
        final rawCpu = double.tryParse(parts[0]) ?? 0.0;
        cpuPercent = (rawCpu / 100.0).clamp(0.0, 1.0);
        load1m = double.tryParse(parts[1]) ?? 0.0;
        cores = int.tryParse(parts[2]) ?? 1;
        if (cores < 1) cores = 1;
      }
    }

    // Line 3: Uptime
    if (lines.length > 3) {
      uptime = lines[3];
    }

    // Line 4: Hostname
    if (lines.length > 4) {
      hostname = lines[4];
    }

    return SystemMetrics(
      cpuPercentage: cpuPercent,
      memoryPercentage: memPercent,
      diskPercentage: diskPercent,
      usedMemMb: usedMemMb,
      totalMemMb: totalMemMb,
      usedDiskGb: usedDiskGb,
      totalDiskGb: totalDiskGb,
      loadAvg1m: load1m,
      cpuCores: cores,
      uptime: uptime,
      hostname: hostname,
      timestamp: DateTime.now(),
    );
  }

  Future<Result<SystemMetrics>> fetchMetrics(SshService ssh) async {
    if (!ssh.isConnected) {
      return Result.failure('Workstation not connected');
    }

    final res = await ssh.runCommand(_metricsScript.trim());
    if (!res.isSuccess) {
      return Result.failure(res.error ?? 'Failed to execute system metrics script');
    }

    final metrics = parseMetricsOutput(res.data ?? '');
    return Result.success(metrics);
  }
}

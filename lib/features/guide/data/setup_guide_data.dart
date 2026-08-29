import 'package:flutter/material.dart';
import '../models/setup_guide_step.dart';

class SetupGuideData {
  static const List<SetupGuideStep> steps = [
    // 1. Quick Start - OpenSSH Install
    SetupGuideStep(
      id: 'install_openssh',
      stepNumber: 1,
      category: SetupCategory.quickStart,
      title: 'Install OpenSSH Server',
      description:
          'OpenSSH Server memungkinkan workstation Linux Anda menerima koneksi remote SSH yang aman dari aplikasi On|Bed.',
      icon: Icons.download_rounded,
      distroSnippets: {
        'Arch / Omarchy': 'sudo pacman -S --needed openssh',
        'Ubuntu / Debian': 'sudo apt update && sudo apt install -y openssh-server',
        'Fedora / RHEL': 'sudo dnf install -y openssh-server',
      },
      tip: 'Sebagian besar distribusi Linux server sudah memiliki OpenSSH terpasang secara default.',
    ),

    // 2. Quick Start - Enable Service
    SetupGuideStep(
      id: 'enable_service',
      stepNumber: 2,
      category: SetupCategory.quickStart,
      title: 'Aktifkan & Jalankan SSH Service',
      description:
          'Jalankan daemon SSH dan atur agar otomatis aktif setiap kali komputer Anda dinyalakan (boot).',
      icon: Icons.play_arrow_rounded,
      distroSnippets: {
        'Arch / Omarchy / Fedora': 'sudo systemctl enable --now sshd',
        'Ubuntu / Debian': 'sudo systemctl enable --now ssh',
      },
      tip: 'Gunakan perintah `sudo systemctl status sshd` untuk memastikan statusnya bernilai "active (running)".',
    ),

    // 3. Quick Start - Check IP Address
    SetupGuideStep(
      id: 'check_ip',
      stepNumber: 3,
      category: SetupCategory.quickStart,
      title: 'Cek Alamat IP Komputer Anda',
      description:
          'Ketahui alamat IP lokal workstation Anda pada jaringan WiFi/LAN untuk dimasukkan ke form koneksi On|Bed.',
      icon: Icons.lan_rounded,
      codeSnippet: 'ip -br a',
      tip: 'Cari interface WiFi (contoh: `wlan0`) atau Ethernet (`eth0` / `enp...`). Alamat IP biasanya berformat `192.168.x.x` atau `10.x.x.x`.',
    ),

    // 4. Tailscale - Zero-Config VPN
    SetupGuideStep(
      id: 'tailscale_install',
      stepNumber: 4,
      category: SetupCategory.tailscale,
      title: 'Akses Dari Mana Saja via Tailscale (Sangat Direkomendasikan)',
      description:
          'Tailscale membuat jaringan VPN mesh privat (WireGuard) sehingga Anda dapat mengakses laptop/PC dari mana saja (luar rumah/kantor) tanpa perlu konfigurasi port forwarding router atau IP statik.',
      icon: Icons.vpn_lock_rounded,
      codeSnippet: 'curl -fsSL https://tailscale.com/install.sh | sh\nsudo tailscale up',
      tip: 'Install aplikasi Tailscale di HP Anda dan login dengan akun yang sama. Anda akan mendapatkan IP privat (100.x.y.z) atau MagicDNS hostname (contoh: `my-laptop.ts.net`).',
    ),

    // 5. Tailscale - Check Tailscale IP
    SetupGuideStep(
      id: 'tailscale_ip',
      stepNumber: 5,
      category: SetupCategory.tailscale,
      title: 'Dapatkan IP Tailscale Workstation',
      description:
          'Gunakan perintah berikut di terminal workstation Anda untuk melihat IP Tailscale yang dapat diinputkan ke On|Bed:',
      icon: Icons.badge_rounded,
      codeSnippet: 'tailscale ip -4',
      tip: 'Masukkan IP ini pada kolom "Host / IP Address" di aplikasi On|Bed untuk koneksi remote dari mana pun.',
    ),

    // 6. SSH Auth - Password Authentication
    SetupGuideStep(
      id: 'ssh_password_auth',
      stepNumber: 6,
      category: SetupCategory.sshAuth,
      title: 'Konfigurasi Autentikasi Password',
      description:
          'Jika Anda ingin login menggunakan password user Linux Anda, pastikan `PasswordAuthentication` diaktifkan di konfigurasi SSH.',
      icon: Icons.password_rounded,
      codeSnippet: 'sudo sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication yes/" /etc/ssh/sshd_config\nsudo systemctl restart sshd',
      tip: 'File konfigurasi SSH terletak di `/etc/ssh/sshd_config` atau direktori `/etc/ssh/sshd_config.d/`.',
    ),

    // 7. SSH Auth - SSH Keypair Setup
    SetupGuideStep(
      id: 'ssh_key_auth',
      stepNumber: 7,
      category: SetupCategory.sshAuth,
      title: 'Setup Autentikasi Kunci SSH (Lebih Aman)',
      description:
          'Untuk keamanan tingkat tinggi tanpa memasukkan password, daftarkan Public Key SSH ke file `authorized_keys` di workstation Anda:',
      icon: Icons.key_rounded,
      codeSnippet: 'mkdir -p ~/.ssh && chmod 700 ~/.ssh\ntouch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys',
      tip: 'Salin Public Key yang Anda miliki atau paste private key Anda langsung ke menu Secure Storage On|Bed.',
    ),

    // 8. SFTP & Neovim - SFTP Subsystem
    SetupGuideStep(
      id: 'sftp_subsystem',
      stepNumber: 8,
      category: SetupCategory.sftpAndTools,
      title: 'Pastikan SFTP Subsystem Aktif',
      description:
          'On|Bed menggunakan protokol SFTP untuk fitur File Explorer dan Code Editor. Pastikan baris subsystem SFTP tidak dikomentari di konfigurasi SSH Anda.',
      icon: Icons.folder_open_rounded,
      distroSnippets: {
        'Arch / Omarchy': 'grep -i "subsystem.*sftp" /etc/ssh/sshd_config || echo "Subsystem sftp /usr/lib/ssh/sftp-server" | sudo tee -a /etc/ssh/sshd_config',
        'Ubuntu / Debian': 'grep -i "subsystem.*sftp" /etc/ssh/sshd_config || echo "Subsystem sftp /usr/lib/openssh/sftp-server" | sudo tee -a /etc/ssh/sshd_config',
      },
      tip: 'Setelah mengubah `/etc/ssh/sshd_config`, jangan lupa jalankan `sudo systemctl restart sshd`.',
    ),

    // 9. SFTP & Neovim - Neovim & Omarchy Best Practices
    SetupGuideStep(
      id: 'neovim_omarchy_tips',
      stepNumber: 9,
      category: SetupCategory.sftpAndTools,
      title: 'Tips Penggunaan Neovim & Tmux di On|Bed',
      description:
          'Terminal On|Bed dioptimalkan untuk editor terminal modern seperti Neovim dan Tmux di Arch Linux/Omarchy:',
      icon: Icons.terminal_rounded,
      codeSnippet: '# Pastikan terminfo xterm-256color terpasang\necho "export TERM=xterm-256color" >> ~/.bashrc\n\n# Pasang tmux jika belum ada\nsudo pacman -S --needed tmux neovim',
      tip: 'Gunakan tombol Virtual D-Pad (Home, End, PgUp, PgDn, Esc, Ctrl+C) di toolbar keyboard On|Bed untuk navigasi Neovim yang sangat nyaman.',
    ),
  ];

  static const List<TroubleshootingFaq> faqs = [
    TroubleshootingFaq(
      question: 'Error: Connection Refused (Port 22)',
      cause: 'Service SSH belum aktif, atau firewall memblokir port 22.',
      solutionExplanation: 'Pastikan service sshd berjalan dan port 22 diizinkan di firewall:',
      solutionSnippet: 'sudo systemctl status sshd\n# Jika pakai UFW (Ubuntu/Debian):\nsudo ufw allow 22/tcp\n# Jika pakai firewalld (Fedora):\nsudo firewall-cmd --add-service=ssh --permanent && sudo firewall-cmd --reload',
    ),
    TroubleshootingFaq(
      question: 'Error: Connection Timed Out',
      cause: 'Alamat IP salah, atau HP dan laptop berada di jaringan yang berbeda tanpa Tailscale.',
      solutionExplanation: 'Pastikan HP dan PC berada dalam 1 jaringan WiFi yang sama, atau hubungkan keduanya ke Tailscale VPN.',
      solutionSnippet: 'tailscale status',
    ),
    TroubleshootingFaq(
      question: 'Error: Permission Denied (publickey / password)',
      cause: 'Username salah, password keliru, atau permission folder `~/.ssh` terlalu longgar.',
      solutionExplanation: 'Perbaiki permission file SSH di workstation Linux:',
      solutionSnippet: 'chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys',
    ),
    TroubleshootingFaq(
      question: 'File Explorer tidak dapat memuat folder (SFTP Error)',
      cause: 'SFTP subsystem belum aktif di sshd_config atau path binary sftp-server berbeda.',
      solutionExplanation: 'Cek baris Subsystem sftp pada file `/etc/ssh/sshd_config` lalu restart SSH daemon.',
      solutionSnippet: 'sudo systemctl restart sshd',
    ),
  ];
}

import 'package:flutter/material.dart';

enum SetupCategory {
  quickStart('Quick Start', Icons.bolt_rounded),
  tailscale('Tailscale VPN', Icons.vpn_lock_rounded),
  sshAuth('SSH & Security', Icons.security_rounded),
  sftpAndTools('SFTP & Neovim', Icons.terminal_rounded),
  troubleshooting('Troubleshooting', Icons.build_circle_outlined);

  final String label;
  final IconData icon;
  const SetupCategory(this.label, this.icon);
}

class SetupGuideStep {
  final String id;
  final int stepNumber;
  final String title;
  final String description;
  final String? codeSnippet;
  final Map<String, String>? distroSnippets; // e.g. {'Arch / Omarchy': '...', 'Ubuntu / Debian': '...', 'Fedora': '...'}
  final IconData icon;
  final String? tip;
  final SetupCategory category;

  const SetupGuideStep({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.description,
    this.codeSnippet,
    this.distroSnippets,
    required this.icon,
    this.tip,
    required this.category,
  });
}

class TroubleshootingFaq {
  final String question;
  final String cause;
  final String solutionExplanation;
  final String? solutionSnippet;

  const TroubleshootingFaq({
    required this.question,
    required this.cause,
    required this.solutionExplanation,
    this.solutionSnippet,
  });
}

import 'package:flutter/material.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String badge;
  final List<String> highlightTags;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.badge,
    required this.highlightTags,
  });
}

const onboardingPages = [
  OnboardingItem(
    title: 'On|Bed',
    subtitle: 'Your Machine, Even in Bed.',
    description:
        'Access and control your Linux development workstation directly from your phone. Thin client architecture with zero cloud dependency.',
    icon: Icons.hub_rounded,
    badge: 'REMOTE DEVELOPMENT',
    highlightTags: ['Linux Workstation', 'Thin Client', 'Zero Latency'],
  ),
  OnboardingItem(
    title: 'Private by Design',
    subtitle: 'Tailscale & Direct SSH',
    description:
        'Connect seamlessly over your private Tailscale network. Your code, secrets, and processes never leave your machine.',
    icon: Icons.security_rounded,
    badge: 'END-TO-END SECURE',
    highlightTags: ['Tailscale MagicDNS', 'SSH Keys', 'Android Keystore'],
  ),
  OnboardingItem(
    title: 'Code. Terminal. Files.',
    subtitle: 'Full Developer Toolchain',
    description:
        'Interactive PTY shell with tmux persistence, SFTP file manager, and syntax-highlighted code editor at your fingertips.',
    icon: Icons.terminal_rounded,
    badge: 'FULL STACK WORKFLOW',
    highlightTags: ['Real Shell (PTY)', 'tmux Sessions', 'AI CLI Ready'],
  ),
];

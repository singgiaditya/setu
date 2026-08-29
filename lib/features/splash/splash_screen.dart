import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/storage_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();
    _bootstrap();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final prefs = ref.read(preferencesStoreProvider);
    final biometricService = ref.read(biometricServiceProvider);

    // Biometric check if enabled
    if (prefs.isBiometricEnabled) {
      final authResult = await biometricService.authenticate(
        reason: 'Unlock On|Bed to access your workstations',
      );
      if (authResult.isFailure && mounted) {
        // Retry dialog or stay
        return;
      }
    }

    if (!mounted) return;

    if (!prefs.hasCompletedOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.18),
                        blurRadius: 36,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.terminal_rounded,
                    size: 46,
                    color: colors.primary,
                  ),
                ),
                const Gap(24),

                // Brand Name (Space Grotesk)
                Text(
                  'On|Bed',
                  style: typography.brand.copyWith(
                    fontSize: 34,
                    letterSpacing: 3.0,
                    color: colors.foreground,
                  ),
                ),
                const Gap(8),

                // Tagline
                Text(
                  'Your Machine, Even in Bed.',
                  style: typography.bodyMedium.copyWith(
                    color: colors.foregroundMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const Gap(48),

                // Subtle Loading Spinner
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

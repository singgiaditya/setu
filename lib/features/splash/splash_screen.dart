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
                // Logo Mark (Phone on Bed with Terminal Prompt)
                Image.asset(
                  'assets/images/logo_mark_512.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                ),
                const Gap(20),

                // Brand Name
                Text(
                  'ONBED',
                  style: typography.brand.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.5,
                    color: colors.foreground,
                  ),
                ),
                const Gap(6),

                // Tagline
                Text(
                  'Your Machine. From Bed.',
                  style: typography.bodyMedium.copyWith(
                    color: colors.foregroundMuted,
                    letterSpacing: 0.5,
                    fontSize: 15,
                  ),
                ),
                const Gap(40),

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

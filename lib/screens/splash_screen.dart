import 'package:material_ui/material_ui.dart';

import '../services/app_controller.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';
import 'profile_form_screen.dart';

/// Tela inicial: apresenta a marca e decide para onde o usuário vai.
/// Usuário novo -> botão "Começar" (cadastro). Usuário que já cadastrou -> Dashboard.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  bool _showStart = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      await Future.wait([
        appController.load(),
        Future<void>.delayed(const Duration(milliseconds: 1800)),
      ]);
      final onboarded = await SessionService.isOnboarded();
      if (!mounted) return;
      if (onboarded && appController.profile != null && appController.goals != null) {
        _go(const HomeShell());
      } else {
        setState(() => _showStart = true);
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _go(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondary) => page,
        transitionsBuilder: (context, animation, secondary, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _anim,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.85, end: 1).animate(
                      CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.purple, AppColors.purpleDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(color: AppColors.purple.withValues(alpha: 0.4), blurRadius: 36),
                            ],
                          ),
                          child: const Icon(Icons.trending_up_rounded, size: 54, color: AppColors.text),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Evolv',
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                        const SizedBox(height: 8),
                        const Text('Sua evolução, no seu ritmo.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 56),
                if (_failed)
                  const Text(
                    'Não foi possível abrir os dados do app. Feche e abra o Evolv novamente.',
                    textAlign: TextAlign.center,
                    style: AppText.secondary,
                  )
                else
                  AnimatedOpacity(
                    opacity: _showStart ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: IgnorePointer(
                      ignoring: !_showStart,
                      child: FilledButton(
                        onPressed: () => _go(const ProfileFormScreen()),
                        child: const Text('Começar'),
                      ),
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

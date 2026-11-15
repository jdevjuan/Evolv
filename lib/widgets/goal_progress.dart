import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Barra de progresso animada. Fica verde quando a meta é atingida.
class GoalProgress extends StatelessWidget {
  const GoalProgress({super.key, required this.value, required this.goal, this.height = 10});

  final num value;
  final num goal;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ratio = goal <= 0 ? 0.0 : (value / goal).clamp(0.0, 1.0).toDouble();
    final reached = goal > 0 && value >= goal;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: ratio),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => LinearProgressIndicator(
          value: v,
          minHeight: height,
          backgroundColor: AppColors.border,
          color: reached ? AppColors.positive : AppColors.purple,
        ),
      ),
    );
  }
}

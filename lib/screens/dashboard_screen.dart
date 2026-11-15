import 'package:material_ui/material_ui.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ui.dart';
import '../widgets/app_card.dart';
import '../widgets/entry_sheets.dart';
import '../widgets/goal_progress.dart';
import 'exercise_screen.dart';
import 'hydration_screen.dart';

/// Tela inicial do dia: resumo de calorias, água, peso e exercícios.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onOpenFood});

  final VoidCallback onOpenFood;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appController,
      builder: (context, _) {
        final firstName = (appController.profile?.name ?? '').split(' ').first;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text('Olá, $firstName!', style: AppText.heading),
              const SizedBox(height: 4),
              const Text('Vamos continuar sua evolução?', style: AppText.body),
              const SizedBox(height: 2),
              Text(longDate(DateTime.now()), style: AppText.secondary),
              const SizedBox(height: 20),
              _Shortcuts(onFood: () => showFoodSheet(context), onWater: () => pushPage(context, const HydrationScreen()), onExercise: () => showExerciseSheet(context)),
              const SizedBox(height: 16),
              _CaloriesCard(onTap: onOpenFood),
              const SizedBox(height: 12),
              const _WaterCard(),
              const SizedBox(height: 12),
              const _WeightCard(),
              const SizedBox(height: 12),
              const _ExerciseCard(),
            ],
          ),
        );
      },
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts({required this.onFood, required this.onWater, required this.onExercise});

  final VoidCallback onFood;
  final VoidCallback onWater;
  final VoidCallback onExercise;

  Widget _button(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: AppColors.purple),
            const SizedBox(height: 6),
            Text(label, style: AppText.secondary.copyWith(color: AppColors.text)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _button(Icons.restaurant_rounded, '+ Alimento', onFood),
        const SizedBox(width: 10),
        _button(Icons.water_drop_rounded, '+ Água', onWater),
        const SizedBox(width: 10),
        _button(Icons.directions_run_rounded, '+ Exercício', onExercise),
      ],
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader(this.icon, this.title, {this.trailing});

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.purple, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: AppText.cardTitle)),
        if (trailing != null) Text(trailing!, style: AppText.secondary),
      ],
    );
  }
}

class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = appController.totalCalories;
    final goal = appController.goals?.dailyCalories ?? 0;
    final diff = goal - total;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(Icons.local_fire_department_rounded, 'Calorias de hoje'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$total', style: AppText.bigNumber),
              Text(' / $goal kcal', style: AppText.secondary),
            ],
          ),
          const SizedBox(height: 10),
          GoalProgress(value: total, goal: goal),
          const SizedBox(height: 8),
          Text(
            diff > 0
                ? 'Restam $diff kcal para a meta'
                : (diff == 0 ? 'Meta de hoje atingida' : 'Meta ultrapassada em ${-diff} kcal'),
            style: AppText.secondary.copyWith(color: diff == 0 ? AppColors.positive : AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard();

  Future<void> _quickAdd(BuildContext context, int ml) async {
    await appController.addWater(ml);
    if (context.mounted) showAppSnack(context, '$ml ml adicionados');
  }

  @override
  Widget build(BuildContext context) {
    final total = appController.totalWater;
    final goal = appController.goals?.dailyWaterMl ?? 0;

    return AppCard(
      onTap: () => pushPage(context, const HydrationScreen()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(Icons.water_drop_rounded, 'Hidratação'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$total', style: AppText.bigNumber),
              Text(' / $goal ml', style: AppText.secondary),
            ],
          ),
          const SizedBox(height: 10),
          GoalProgress(value: total, goal: goal),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => _quickAdd(context, 200), child: const Text('+ 200 ml'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(onPressed: () => _quickAdd(context, 500), child: const Text('+ 500 ml'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeightCard extends StatelessWidget {
  const _WeightCard();

  Widget _value(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.secondary),
          const SizedBox(height: 4),
          Text(value, style: AppText.bigNumber.copyWith(fontSize: 24)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = appController.profile?.weightKg;
    final target = appController.goals?.targetWeight;
    final diff = (current != null && target != null) ? (current - target).abs() : null;

    return AppCard(
      onTap: () => showWeightSheet(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(Icons.monitor_weight_rounded, 'Peso', trailing: 'Toque para registrar'),
          const SizedBox(height: 12),
          Row(
            children: [
              _value('Peso atual', current == null ? '--' : '${fmtNum(current)} kg'),
              _value('Peso desejado', target == null ? '--' : '${fmtNum(target)} kg'),
            ],
          ),
          if (diff != null) ...[
            const SizedBox(height: 10),
            Text(
              diff < 0.05 ? 'Você está no peso desejado' : 'Faltam ${fmtNum(diff)} kg para a meta',
              style: AppText.secondary.copyWith(color: diff < 0.05 ? AppColors.positive : AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard();

  @override
  Widget build(BuildContext context) {
    final items = appController.todayExercises;

    return AppCard(
      onTap: () => pushPage(context, const ExerciseScreen()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(Icons.directions_run_rounded, 'Exercícios de hoje', trailing: items.isEmpty ? null : '${appController.todayMinutes} min'),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text('Nenhuma atividade registrada hoje. Toque para ver ou registrar.', style: AppText.secondary)
          else ...[
            for (final e in items.take(3))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text(e.name, style: AppText.body)),
                    Text('${e.minutes} min', style: AppText.secondary),
                  ],
                ),
              ),
            if (items.length > 3) Text('+ ${items.length - 3} atividade(s)', style: AppText.secondary),
          ],
        ],
      ),
    );
  }
}

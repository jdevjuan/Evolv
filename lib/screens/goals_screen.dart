import 'package:material_ui/material_ui.dart';

import '../models/goals.dart';
import '../models/user_profile.dart';
import '../services/app_controller.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ui.dart';
import '../widgets/quick_form.dart';
import 'home_shell.dart';

/// Escolha do objetivo e definição manual das metas (passo 2 de 2).
/// Também usada para editar as metas depois.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key, this.editing = false});

  final bool editing;

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  static const _icons = {
    Objective.lose: Icons.trending_down_rounded,
    Objective.gain: Icons.trending_up_rounded,
    Objective.muscle: Icons.fitness_center_rounded,
    Objective.maintain: Icons.drag_handle_rounded,
  };

  Objective? _objective = appController.profile?.objective;

  Future<void> _save(List<String> v) async {
    final objective = _objective;
    if (objective == null) {
      showAppSnack(context, 'Escolha um objetivo para continuar', error: true);
      return;
    }
    await appController.saveGoals(
      objective,
      Goals(
        targetWeight: parseDecimal(v[0])!,
        dailyCalories: parseInteger(v[1])!,
        dailyWaterMl: parseInteger(v[2])!,
      ),
    );
    if (!mounted) return;
    if (widget.editing) {
      showAppSnack(context, 'Metas atualizadas');
      Navigator.of(context).pop();
    } else {
      await SessionService.setOnboarded();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (route) => false,
      );
    }
  }

  Widget _objectiveOption(Objective o) {
    final selected = _objective == o;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _objective = o),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.purple.withValues(alpha: 0.15) : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppColors.purple : AppColors.border, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Icon(_icons[o], color: selected ? AppColors.purple : AppColors.textSecondary),
              const SizedBox(width: 14),
              Expanded(child: Text(o.label, style: AppText.body.copyWith(fontWeight: FontWeight.w600))),
              if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.purple),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.editing ? appController.goals : null;

    return Scaffold(
      appBar: widget.editing ? AppBar(title: const Text('Editar metas')) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.editing) ...[
                const Text('Passo 2 de 2', style: AppText.secondary),
                const SizedBox(height: 8),
                const Text('Qual é o seu objetivo?', style: AppText.heading),
                const SizedBox(height: 8),
                const Text('Você define as suas próprias metas, no seu ritmo.', style: AppText.secondary),
                const SizedBox(height: 24),
              ],
              QuickForm(
                submitLabel: widget.editing ? 'Salvar metas' : 'Concluir',
                header: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.editing) ...[
                      const Text('Objetivo', style: AppText.cardTitle),
                      const SizedBox(height: 12),
                    ],
                    for (final o in Objective.values) _objectiveOption(o),
                    const SizedBox(height: 10),
                    const Text('Suas metas', style: AppText.cardTitle),
                  ],
                ),
                fields: [
                  FieldSpec('Peso desejado', kind: FieldKind.decimal, suffix: 'kg', min: 20, max: 400, initial: g == null ? null : fmtNum(g.targetWeight)),
                  FieldSpec('Meta diária de calorias', kind: FieldKind.integer, suffix: 'kcal', max: 20000, initial: g?.dailyCalories.toString()),
                  FieldSpec('Meta diária de água', kind: FieldKind.integer, suffix: 'ml', max: 10000, initial: g?.dailyWaterMl.toString()),
                ],
                onSubmit: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

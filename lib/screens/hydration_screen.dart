import 'package:material_ui/material_ui.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/ui.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_sheets.dart';
import '../widgets/entry_tile.dart';
import '../widgets/goal_progress.dart';

/// Acompanhamento do consumo de água do dia.
class HydrationScreen extends StatelessWidget {
  const HydrationScreen({super.key});

  Future<void> _add(BuildContext context, int ml) async {
    await appController.addWater(ml);
    if (context.mounted) showAppSnack(context, '$ml ml adicionados');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hidratação')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: appController,
          builder: (context, _) {
            final total = appController.totalWater;
            final goal = appController.goals?.dailyWaterMl ?? 0;
            final percent = goal <= 0 ? 0 : (total * 100 / goal).round();
            final entries = appController.water;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('$total', style: AppText.bigNumber.copyWith(fontSize: 40)),
                          Text(' / $goal ml', style: AppText.secondary),
                          const Spacer(),
                          Text('$percent%', style: AppText.cardTitle.copyWith(color: AppColors.purple)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GoalProgress(value: total, goal: goal, height: 14),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: FilledButton(onPressed: () => _add(context, 200), child: const Text('+ 200 ml'))),
                    const SizedBox(width: 10),
                    Expanded(child: FilledButton(onPressed: () => _add(context, 500), child: const Text('+ 500 ml'))),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => showWaterSheet(context),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Outra quantidade'),
                ),
                const SizedBox(height: 24),
                const Text('Registros de hoje', style: AppText.cardTitle),
                const SizedBox(height: 8),
                if (entries.isEmpty)
                  const EmptyState(
                    icon: Icons.water_drop_rounded,
                    title: 'Nenhuma água registrada hoje',
                    message: 'Use os botões acima para registrar cada copo ou garrafa.',
                  )
                else
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TileList(
                      children: [
                        for (final w in entries)
                          EntryTile(
                            icon: Icons.water_drop_rounded,
                            title: '${w.ml} ml',
                            subtitle: w.time,
                            onDelete: () async {
                              await appController.deleteWater(w.id!);
                              if (context.mounted) showAppSnack(context, 'Registro excluído');
                            },
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

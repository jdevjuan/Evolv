import 'package:material_ui/material_ui.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ui.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_sheets.dart';
import '../widgets/entry_tile.dart';
import '../widgets/goal_progress.dart';

/// Registro e lista dos alimentos de hoje, comparando com a meta de calorias.
class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appController,
      builder: (context, _) {
        final foods = appController.foods;
        final total = appController.totalCalories;
        final goal = appController.goals?.dailyCalories ?? 0;

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showFoodSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Adicionar'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              children: [
                const Text('Alimentação', style: AppText.heading),
                const SizedBox(height: 2),
                Text(longDate(DateTime.now()), style: AppText.secondary),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total do dia', style: AppText.secondary),
                      const SizedBox(height: 6),
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Registros de hoje', style: AppText.cardTitle),
                const SizedBox(height: 8),
                if (foods.isEmpty)
                  const EmptyState(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Nenhum alimento registrado',
                    message: 'Toque em "Adicionar" para registrar o que você comeu hoje.',
                  )
                else
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TileList(
                      children: [
                        for (final f in foods)
                          EntryTile(
                            icon: Icons.restaurant_rounded,
                            title: f.name,
                            subtitle: '${f.portion} • ${f.time}',
                            trailing: '${f.calories} kcal',
                            onDelete: () async {
                              await appController.deleteFood(f.id!);
                              if (context.mounted) showAppSnack(context, 'Alimento excluído');
                            },
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

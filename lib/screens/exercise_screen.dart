import 'package:material_ui/material_ui.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ui.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_sheets.dart';
import '../widgets/entry_tile.dart';

/// Registro de atividades físicas (últimos 30 dias).
class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  Widget _stat(String label, String value) {
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
    return ListenableBuilder(
      listenable: appController,
      builder: (context, _) {
        final items = appController.recentExercises;

        return Scaffold(
          appBar: AppBar(title: const Text('Exercícios')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showExerciseSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Registrar'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      _stat('Hoje', '${appController.todayMinutes} min'),
                      _stat('Últimos 7 dias', '${appController.weekMinutes} min'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Atividades recentes', style: AppText.cardTitle),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const EmptyState(
                    icon: Icons.directions_run_rounded,
                    title: 'Nenhum exercício registrado',
                    message: 'Toque em "Registrar" para anotar sua caminhada, corrida, treino ou outra atividade.',
                  )
                else
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TileList(
                      children: [
                        for (final e in items)
                          EntryTile(
                            icon: Icons.fitness_center_rounded,
                            title: e.name,
                            subtitle: friendlyDate(e.date),
                            trailing: '${e.minutes} min',
                            onDelete: () async {
                              await appController.deleteExercise(e.id!);
                              if (context.mounted) showAppSnack(context, 'Exercício excluído');
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

import 'package:material_ui/material_ui.dart';

import '../database/app_database.dart';
import '../models/day_data.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_tile.dart';

/// Consulta de registros anteriores, organizados por data.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Future<List<String>> _dates = AppDatabase.instance.historyDates();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: SafeArea(
        child: FutureBuilder<List<String>>(
          future: _dates,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Não foi possível carregar o histórico.', style: AppText.secondary));
            }
            final dates = snapshot.data;
            if (dates == null) return const Center(child: CircularProgressIndicator());
            if (dates.isEmpty) {
              return const Center(
                child: EmptyState(
                  icon: Icons.history_rounded,
                  title: 'Nada por aqui ainda',
                  message: 'Seus registros de alimentação, água, exercícios e peso aparecerão aqui, separados por dia.',
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: dates.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _DayTile(date: dates[index]),
            );
          },
        ),
      ),
    );
  }
}

/// Um dia do histórico. Os detalhes são carregados só quando o item aparece na tela.
class _DayTile extends StatefulWidget {
  const _DayTile({required this.date});

  final String date;

  @override
  State<_DayTile> createState() => _DayTileState();
}

class _DayTileState extends State<_DayTile> {
  late final Future<DayData> _future = AppDatabase.instance.dayData(widget.date);

  String _summary(DayData d) {
    final parts = <String>[
      if (d.foods.isNotEmpty) '${d.foods.length} alimento(s) • ${d.calories} kcal',
      if (d.water.isNotEmpty) '${d.waterMl} ml de água',
      if (d.exercises.isNotEmpty) '${d.minutes} min de exercício',
      if (d.weight != null) '${fmtNum(d.weight!.kg)} kg',
    ];
    return parts.join('  |  ');
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 2),
        child: Text(text, style: AppText.secondary.copyWith(fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final title = friendlyDate(widget.date, weekday: true);

    return FutureBuilder<DayData>(
      future: _future,
      builder: (context, snapshot) {
        final d = snapshot.data;
        if (d == null) {
          return AppCard(child: Text(title, style: AppText.cardTitle));
        }
        return AppCard(
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              title: Text(title, style: AppText.cardTitle),
              subtitle: Text(_summary(d), style: AppText.secondary),
              children: [
                if (d.weight != null) ...[
                  _heading('Peso'),
                  EntryTile(icon: Icons.monitor_weight_rounded, title: 'Peso registrado', trailing: '${fmtNum(d.weight!.kg)} kg'),
                ],
                if (d.foods.isNotEmpty) ...[
                  _heading('Alimentos'),
                  for (final f in d.foods)
                    EntryTile(
                      icon: Icons.restaurant_rounded,
                      title: f.name,
                      subtitle: '${f.portion} • ${f.time}',
                      trailing: '${f.calories} kcal',
                    ),
                ],
                if (d.water.isNotEmpty) ...[
                  _heading('Água'),
                  EntryTile(
                    icon: Icons.water_drop_rounded,
                    title: 'Total do dia',
                    subtitle: '${d.water.length} registro(s)',
                    trailing: '${d.waterMl} ml',
                  ),
                ],
                if (d.exercises.isNotEmpty) ...[
                  _heading('Exercícios'),
                  for (final e in d.exercises)
                    EntryTile(icon: Icons.fitness_center_rounded, title: e.name, trailing: '${e.minutes} min'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

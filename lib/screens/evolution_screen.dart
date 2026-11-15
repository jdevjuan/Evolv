import 'package:material_ui/material_ui.dart';

import '../database/app_database.dart';
import '../models/weight_entry.dart';
import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ui.dart';
import '../widgets/app_card.dart';
import '../widgets/charts.dart';
import '../widgets/entry_sheets.dart';
import 'history_screen.dart';

/// Dados já carregados para o período escolhido.
class _EvolutionData {
  const _EvolutionData({
    required this.start,
    required this.days,
    required this.weights,
    required this.calories,
    required this.water,
    required this.minutes,
  });

  final DateTime start;
  final int days;
  final List<WeightEntry> weights;
  final Map<String, int> calories;
  final Map<String, int> water;
  final Map<String, int> minutes;

  List<String> get dayKeys => [
        for (var i = 0; i < days; i++) dateKey(DateTime(start.year, start.month, start.day + i)),
      ];

  List<double> series(Map<String, int> source, {double divisor = 1}) =>
      [for (final k in dayKeys) (source[k] ?? 0) / divisor];
}

/// Gráficos de evolução: peso, calorias, água e exercícios por período.
class EvolutionScreen extends StatefulWidget {
  const EvolutionScreen({super.key});

  @override
  State<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends State<EvolutionScreen> {
  static const _periods = [7, 30, 90];

  int _days = 7;
  late Future<_EvolutionData> _future = _load();

  Future<_EvolutionData> _load() async {
    final db = AppDatabase.instance;
    final start = daysAgo(_days - 1);
    final since = dateKey(start);
    return _EvolutionData(
      start: start,
      days: _days,
      weights: await db.weightsSince(since),
      calories: await db.caloriesByDay(since),
      water: await db.waterByDay(since),
      minutes: await db.minutesByDay(since),
    );
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _registerWeight() async {
    await showWeightSheet(context);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              const Expanded(child: Text('Evolução', style: AppText.heading)),
              IconButton(
                tooltip: 'Histórico',
                onPressed: () => pushPage(context, const HistoryScreen()),
                icon: const Icon(Icons.history_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final p in _periods)
                ChoiceChip(
                  label: Text('$p dias'),
                  selected: _days == p,
                  showCheckmark: false,
                  onSelected: (_) {
                    _days = p;
                    _reload();
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<_EvolutionData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Não foi possível carregar os dados.', style: AppText.secondary);
              }
              final data = snapshot.data;
              if (data == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _content(data);
            },
          ),
        ],
      ),
    );
  }

  Widget _content(_EvolutionData data) {
    final goals = appController.goals;
    final keys = data.dayKeys;

    return Column(
      children: [
        _weightSection(data),
        const SizedBox(height: 16),
        _barSection(
          title: 'Calorias por dia',
          icon: Icons.local_fire_department_rounded,
          hasData: data.calories.isNotEmpty,
          emptyMessage: 'Registre alimentos para ver o consumo de calorias neste período.',
          chart: BarSeriesChart(
            dayKeys: keys,
            values: data.series(data.calories),
            goal: goals?.dailyCalories.toDouble(),
            formatY: (v) => fmtNum(v, decimals: 0),
          ),
          caption: _average(data.calories, 'kcal', 'Média nos dias com registro'),
        ),
        const SizedBox(height: 16),
        _barSection(
          title: 'Água por dia',
          icon: Icons.water_drop_rounded,
          hasData: data.water.isNotEmpty,
          emptyMessage: 'Registre sua hidratação para ver o consumo de água neste período.',
          chart: BarSeriesChart(
            dayKeys: keys,
            values: data.series(data.water, divisor: 1000),
            goal: goals == null ? null : goals.dailyWaterMl / 1000,
            formatY: (v) => '${fmtNum(v)} L',
          ),
          caption: _average(data.water, 'ml', 'Média nos dias com registro'),
        ),
        const SizedBox(height: 16),
        _barSection(
          title: 'Exercícios (minutos por dia)',
          icon: Icons.directions_run_rounded,
          hasData: data.minutes.isNotEmpty,
          emptyMessage: 'Registre exercícios para ver sua frequência neste período.',
          chart: BarSeriesChart(
            dayKeys: keys,
            values: data.series(data.minutes),
            formatY: (v) => fmtNum(v, decimals: 0),
          ),
          caption: '${data.minutes.length} dia(s) com exercício em ${data.days} dias',
        ),
      ],
    );
  }

  String _average(Map<String, int> source, String unit, String label) {
    if (source.isEmpty) return '';
    final avg = source.values.reduce((a, b) => a + b) / source.length;
    return '$label: ${fmtNum(avg, decimals: 0)} $unit';
  }

  Widget _sectionCard({required IconData icon, required String title, Widget? action, required List<Widget> children}) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.purple, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppText.cardTitle)),
              ?action,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _barSection({
    required String title,
    required IconData icon,
    required bool hasData,
    required String emptyMessage,
    required Widget chart,
    required String caption,
  }) {
    return _sectionCard(
      icon: icon,
      title: title,
      children: hasData
          ? [chart, const SizedBox(height: 10), Text(caption, style: AppText.secondary)]
          : [Text(emptyMessage, style: AppText.secondary)],
    );
  }

  Widget _weightSection(_EvolutionData data) {
    final weights = data.weights;
    final canDraw = weights.length >= 2;
    final target = appController.goals?.targetWeight;

    Widget summary = const SizedBox.shrink();
    if (canDraw) {
      final first = weights.first.kg;
      final last = weights.last.kg;
      final change = last - first;
      // Verde quando a variação aproxima o usuário do peso desejado.
      final towardGoal = target != null && (last - target).abs() < (first - target).abs();
      summary = Text(
        '${change > 0 ? '+' : ''}${fmtNum(change)} kg no período',
        style: AppText.secondary.copyWith(color: towardGoal ? AppColors.positive : AppColors.textSecondary),
      );
    }

    return _sectionCard(
      icon: Icons.monitor_weight_rounded,
      title: 'Peso',
      action: TextButton(onPressed: _registerWeight, child: const Text('Registrar')),
      children: canDraw
          ? [
              WeightLineChart(entries: weights, start: data.start, days: data.days),
              const SizedBox(height: 10),
              summary,
            ]
          : [
              Text(
                weights.isEmpty
                    ? 'Registre seu peso para começar a acompanhar a evolução.'
                    : 'Registre seu peso em pelo menos dois dias diferentes para ver o gráfico.',
                style: AppText.secondary,
              ),
            ],
    );
  }
}

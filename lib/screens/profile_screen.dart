import 'package:material_ui/material_ui.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ui.dart';
import '../widgets/app_card.dart';
import 'goals_screen.dart';
import 'history_screen.dart';
import 'profile_form_screen.dart';

/// Mostra os dados pessoais e as metas, com atalhos para editar.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.secondary)),
          Text(value, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.purple),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppText.body.copyWith(fontWeight: FontWeight.w600))),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appController,
      builder: (context, _) {
        final p = appController.profile;
        final g = appController.goals;
        final name = p?.name ?? '';

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text('Perfil', style: AppText.heading),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.purple.withValues(alpha: 0.2),
                      child: Text(
                        name.isEmpty ? '?' : name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.purple),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: AppText.cardTitle.copyWith(fontSize: 20)),
                    const SizedBox(height: 12),
                    _row('Idade', p == null ? '--' : '${p.age} anos'),
                    _row('Altura', p == null ? '--' : '${fmtNum(p.heightCm)} cm'),
                    _row('Peso atual', p == null ? '--' : '${fmtNum(p.weightKg)} kg'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Minhas metas', style: AppText.cardTitle),
                    const SizedBox(height: 8),
                    _row('Objetivo', p?.objective?.label ?? '--'),
                    _row('Peso desejado', g == null ? '--' : '${fmtNum(g.targetWeight)} kg'),
                    _row('Calorias por dia', g == null ? '--' : '${g.dailyCalories} kcal'),
                    _row('Água por dia', g == null ? '--' : '${g.dailyWaterMl} ml'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _action(Icons.edit_rounded, 'Editar perfil', () => pushPage(context, const ProfileFormScreen(editing: true))),
              const SizedBox(height: 10),
              _action(Icons.flag_rounded, 'Editar objetivo e metas', () => pushPage(context, const GoalsScreen(editing: true))),
              const SizedBox(height: 10),
              _action(Icons.history_rounded, 'Histórico de registros', () => pushPage(context, const HistoryScreen())),
            ],
          ),
        );
      },
    );
  }
}

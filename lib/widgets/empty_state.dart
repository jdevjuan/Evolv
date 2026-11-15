import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Mensagem exibida quando ainda não há registros, orientando o usuário.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.purple, size: 30),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppText.cardTitle, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, style: AppText.secondary, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

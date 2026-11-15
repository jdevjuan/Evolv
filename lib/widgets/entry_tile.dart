import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Linha de um registro (alimento, água, exercício, peso).
/// Se [onDelete] for informado, mostra o botão de excluir.
class EntryTile extends StatelessWidget {
  const EntryTile({super.key, required this.icon, required this.title, this.subtitle, this.trailing, this.onDelete});

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
                if (subtitle != null) Text(subtitle!, style: AppText.secondary),
              ],
            ),
          ),
          if (trailing != null) Text(trailing!, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}

/// Coloca divisórias entre os itens de uma lista dentro de um card.
class TileList extends StatelessWidget {
  const TileList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.border),
          children[i],
        ],
      ],
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

void showAppSnack(BuildContext context, String message, {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: error ? AppColors.negative : AppColors.positive,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

Future<T?> pushPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
}

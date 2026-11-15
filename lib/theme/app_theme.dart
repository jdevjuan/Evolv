import 'package:material_ui/material_ui.dart';

/// Paleta de cores do Evolv (preto + roxo).
class AppColors {
  static const background = Color(0xFF0D0D0F);
  static const card = Color(0xFF19191F);
  static const border = Color(0xFF2A2A33);
  static const purple = Color(0xFF8B5CF6);
  static const purpleDark = Color(0xFF6D28D9);
  static const text = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A1AA);
  static const positive = Color(0xFF4ADE80);
  static const negative = Color(0xFFF87171);
}

/// Estilos de texto reutilizados nas telas.
class AppText {
  static const heading = TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text);
  static const cardTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text);
  static const bigNumber = TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.text);
  static const body = TextStyle(fontSize: 15, color: AppColors.text);
  static const secondary = TextStyle(fontSize: 13, color: AppColors.textSecondary);
}

class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.purple,
      onPrimary: AppColors.text,
      secondary: AppColors.purpleDark,
      onSecondary: AppColors.text,
      surface: AppColors.card,
      onSurface: AppColors.text,
      error: AppColors.negative,
    );

    OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color),
        );

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        border: inputBorder(AppColors.border),
        enabledBorder: inputBorder(AppColors.border),
        focusedBorder: inputBorder(AppColors.purple),
        errorBorder: inputBorder(AppColors.negative),
        focusedErrorBorder: inputBorder(AppColors.negative),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: AppColors.text,
          minimumSize: const Size.fromHeight(52),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(0, 44),
          shape: buttonShape,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.purple,
        foregroundColor: AppColors.text,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.purple.withValues(alpha: 0.30),
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(color: AppColors.text),
        shape: const StadiumBorder(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.card,
        contentTextStyle: const TextStyle(color: AppColors.text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.purple.withValues(alpha: 0.25),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? AppColors.text : AppColors.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.purple : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

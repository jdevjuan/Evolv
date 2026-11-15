import 'formatters.dart';

String? validateRequired(String? raw) {
  if ((raw ?? '').trim().isEmpty) return 'Preencha este campo';
  return null;
}

/// Valida números digitados pelo usuário (obrigatório, numérico e dentro do intervalo).
String? validateNumber(String? raw, {required bool integer, double min = 1, double max = 100000}) {
  final required = validateRequired(raw);
  if (required != null) return required;
  final n = integer ? parseInteger(raw!) : parseDecimal(raw!);
  if (n == null) return 'Digite um número válido';
  if (n < min || n > max) return 'Informe um valor entre ${fmtNum(min)} e ${fmtNum(max)}';
  return null;
}

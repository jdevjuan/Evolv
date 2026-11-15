import 'package:intl/intl.dart';

/// Datas são guardadas no banco como texto "yyyy-MM-dd" e horas como "HH:mm".
String dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
String todayKey() => dateKey(DateTime.now());
String timeNow() => DateFormat('HH:mm').format(DateTime.now());
DateTime parseKey(String key) => DateTime.parse(key);

DateTime daysAgo(int days) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - days);
}

String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Ex.: "Domingo, 15 de novembro"
String longDate(DateTime d) => capitalize(DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(d));

/// Ex.: "15/11"
String shortDate(String key) => DateFormat('dd/MM').format(parseKey(key));

/// "Hoje", "Ontem" ou a data completa.
String friendlyDate(String key, {bool weekday = false}) {
  if (key == todayKey()) return 'Hoje';
  if (key == dateKey(daysAgo(1))) return 'Ontem';
  final d = parseKey(key);
  if (weekday) return capitalize(DateFormat('EEEE, dd/MM/yyyy', 'pt_BR').format(d));
  return DateFormat('dd/MM/yyyy').format(d);
}

/// Aceita vírgula ou ponto como separador decimal.
double? parseDecimal(String s) => double.tryParse(s.trim().replaceAll(',', '.'));
int? parseInteger(String s) => int.tryParse(s.trim());

/// 70.0 -> "70" | 70.5 -> "70,5"
String fmtNum(num v, {int decimals = 1}) {
  final s = v.toStringAsFixed(decimals);
  final trimmed = s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
  return trimmed.replaceAll('.', ',');
}

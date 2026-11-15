import 'package:flutter_test/flutter_test.dart';

import 'package:evolv/utils/formatters.dart';
import 'package:evolv/utils/validators.dart';

void main() {
  group('formatters', () {
    test('parseDecimal aceita vírgula e ponto', () {
      expect(parseDecimal('70,5'), 70.5);
      expect(parseDecimal('70.5'), 70.5);
      expect(parseDecimal('abc'), isNull);
    });

    test('fmtNum remove zeros desnecessários e usa vírgula', () {
      expect(fmtNum(70.0), '70');
      expect(fmtNum(70.5), '70,5');
      expect(fmtNum(2000, decimals: 0), '2000');
    });

    test('dateKey usa o formato yyyy-MM-dd', () {
      expect(dateKey(DateTime(2026, 11, 5)), '2026-11-05');
    });
  });

  group('validators', () {
    test('campo vazio é inválido', () {
      expect(validateRequired('  '), isNotNull);
      expect(validateRequired('Maria'), isNull);
    });

    test('número fora do intervalo é inválido', () {
      expect(validateNumber('0', integer: true), isNotNull);
      expect(validateNumber('2000', integer: true, max: 10000), isNull);
      expect(validateNumber('1,5', integer: true), isNotNull);
      expect(validateNumber('72,5', integer: false, min: 20, max: 400), isNull);
    });
  });
}

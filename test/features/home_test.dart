import 'package:digital_wellbeing_app/core/utils/date_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

// Helpers used by the Home dashboard and the screen-time screens.
void main() {
  group('formatMinutes', () {
    test('formats minutes, hours and mixed durations', () {
      expect(formatMinutes(0), '0m');
      expect(formatMinutes(45), '45m');
      expect(formatMinutes(60), '1h');
      expect(formatMinutes(150), '2h 30m');
    });
  });

  group('dates', () {
    test('dateOnly drops the time of day', () {
      expect(dateOnly(DateTime(2026, 11, 11, 23, 59)), DateTime(2026, 11, 11));
    });

    test('dateKey is a zero-padded yyyy-MM-dd string', () {
      expect(dateKey(DateTime(2026, 3, 7, 10)), '2026-03-07');
    });

    test('formatDate is short and readable', () {
      expect(formatDate(DateTime(2026, 11, 11)), 'Nov 11, 2026');
    });
  });
}

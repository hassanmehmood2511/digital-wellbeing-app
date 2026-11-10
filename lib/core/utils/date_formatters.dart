/// Shared date and duration helpers.
library;

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Nov 11, 2026".
String formatDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

/// Minutes as a short duration: "45m", "2h", "1h 30m".
String formatMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return '${rest}m';
  if (rest == 0) return '${hours}h';
  return '${hours}h ${rest}m';
}

/// The calendar day of [date] (time set to midnight, local time).
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// `yyyy-MM-dd` for a calendar day, as stored in database `date` columns.
String dateKey(DateTime date) {
  final d = dateOnly(date);
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

import 'package:timeago/timeago.dart' as timeago;

bool _localesRegistered = false;

void _ensureLocales() {
  if (_localesRegistered) return;
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());
  _localesRegistered = true;
}

// Manual month names avoid depending on intl date-symbol initialization.
const List<String> _arMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];
const List<String> _enMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Formats a notification timestamp: relative ("منذ ساعتين"/"أمس") for the last
/// 7 days, absolute ("20 يناير") for anything older. Matches the Figma.
String formatNotificationDate(DateTime date, {required bool isArabic}) {
  _ensureLocales();
  final lang = isArabic ? 'ar' : 'en';
  final now = DateTime.now();
  final diff = now.difference(date);

  // Future timestamps or anything within the last week → relative.
  if (diff.isNegative || diff.inDays < 7) {
    return timeago.format(date, locale: lang);
  }

  final months = isArabic ? _arMonths : _enMonths;
  final monthName = months[(date.month - 1).clamp(0, 11)];
  return '${date.day} $monthName';
}

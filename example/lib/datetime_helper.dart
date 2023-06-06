import 'package:intl/intl.dart';

class DateTimeHelper {
  static String timestampToString(
    int timestamp, {
    String toFormat = 'HH:mm',
  }) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat(toFormat).format(date);
  }
}

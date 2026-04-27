import 'package:intl/intl.dart';

/// Formatierungs-Hilfsfunktionen
class Formatters {
  /// Formatiert einen Preis in CHF
  static String price(double value) {
    return NumberFormat.currency(
      locale: 'de_CH',
      symbol: 'CHF',
      decimalDigits: 2,
    ).format(value);
  }

  /// Formatiert einen Preis ohne Währung
  static String priceWithoutCurrency(double value) {
    return NumberFormat('#,##0.00', 'de_CH').format(value);
  }

  /// Formatiert ein Datum (dd.MM.yyyy)
  static String date(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  /// Formatiert ein Datum mit Wochentag
  static String dateWithWeekday(DateTime date) {
    return DateFormat('EEEE, dd.MM.yyyy', 'de_CH').format(date);
  }

  /// Formatiert Datum und Uhrzeit
  static String dateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  /// Formatiert nur die Uhrzeit
  static String time(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Formatiert eine Dauer in lesbare Form
  static String duration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes == 0) {
      return '${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  /// Formatiert eine Telefonnummer für die Schweiz
  static String phoneNumber(String phone) {
    // Einfache Formatierung: 076 123 45 67
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digits.length == 10) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 8)} ${digits.substring(8)}';
    }
    return phone;
  }

  /// Relative Zeitangabe (vor 5 Minuten, etc.)
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Gerade eben';
    } else if (diff.inMinutes < 60) {
      return 'vor ${diff.inMinutes} Min.';
    } else if (diff.inHours < 24) {
      return 'vor ${diff.inHours} Std.';
    } else if (diff.inDays < 7) {
      return 'vor ${diff.inDays} Tagen';
    } else {
      return date(dateTime);
    }
  }

  /// Formatiert Prozentsatz
  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  /// Formatiert Zimmerzahl (3.5 Zimmer)
  static String roomCount(double count) {
    if (count == count.roundToDouble()) {
      return '${count.toInt()} Zimmer';
    }
    return '$count Zimmer';
  }

  /// Kurzes Datumsformat (15. Jan)
  static String dateShort(DateTime date) {
    return DateFormat('d. MMM', 'de_CH').format(date);
  }
}

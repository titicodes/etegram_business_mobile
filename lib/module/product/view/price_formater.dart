import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PriceInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,##0.00", "en_US");

  Price inputFormatter(String text) {
    final cleanedText = text.replaceAll(RegExp(r'[^\d.]'), '');
    final parts = cleanedText.split('.');
    final integerPart = parts[0].isEmpty ? '0' : parts[0];
    var decimalPart = parts.length > 1 ? parts[1] : '';
    decimalPart = decimalPart.padRight(2, '0').substring(0, 2);
    final number = double.tryParse('$integerPart.$decimalPart') ?? 0.0;
    return Price(
      formatted: _formatter.format(number),
      raw: number,
      integerLength: integerPart.length,
      decimalLength: decimalPart.length,
    );
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Handle empty input
    if (newValue.text.isEmpty) {
      return newValue.copyWith(
        text: '0.00',
        selection: const TextSelection.collapsed(offset: 1),
      );
    }

    // Remove non-numeric characters (except decimal point)
    final newText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Reject multiple decimal points
    if (newText.split('.').length > 2) {
      return oldValue;
    }

    // Parse and format the input
    final price = inputFormatter(newValue.text);
    final formattedText = price.formatted;

    // Calculate cursor position
    int newCursorPos = newValue.selection.baseOffset;
    final isDeleting = newValue.text.length < oldValue.text.length;
    final hasDecimal = newValue.text.contains('.');

    if (isDeleting) {
      // When deleting, adjust cursor to avoid jumping
      if (newValue.text.endsWith('.')) {
        newCursorPos = newText.length - 1; // Before the decimal
      } else if (!hasDecimal) {
        newCursorPos = formattedText.length - 3; // Before .00
      } else {
        final decimalPart = newText.split('.').length > 1 ? newText.split('.')[1] : '';
        newCursorPos = formattedText.length - (2 - decimalPart.length).clamp(0, 2);
      }
    } else {
      // When typing, place cursor based on input
      if (hasDecimal) {
        final decimalPart = newText.split('.').length > 1 ? newText.split('.')[1] : '';
        newCursorPos = formattedText.length - (2 - decimalPart.length).clamp(0, 2);
      } else {
        newCursorPos = formattedText.length - 3;
      }
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: newCursorPos.clamp(0, formattedText.length),
      ),
    );
  }
}

class Price {
  final String formatted;
  final double raw;
  final int integerLength;
  final int decimalLength;

  Price({
    required this.formatted,
    required this.raw,
    required this.integerLength,
    required this.decimalLength,
  });
}
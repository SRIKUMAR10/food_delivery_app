import 'package:intl/intl.dart';

void main() {
  final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  print('PRICE1: [${fmt.format(150.0)}]');
  print('PRICE2: [${fmt.format(120.0)}]');
}
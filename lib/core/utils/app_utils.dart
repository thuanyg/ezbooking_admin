import 'dart:math';

String generateRandomString(int len) {
  final start = pow(10, (len - 1));
  final end = pow(10, len) - 1;
  Random random = Random();
  final x = random.nextInt(end.toInt()) + start;

  return x.toString();
}
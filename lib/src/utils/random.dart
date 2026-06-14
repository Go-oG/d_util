import 'dart:math';
import 'dart:ui';

final class RandomUtil {
  RandomUtil._();

  static final _random = Random();

  static num roundFun(num value, int n) {
    return (value * pow(10, n)).round() / pow(10, n);
  }

  static double random() => _random.nextDouble();

  static int randomInt(int min, int max) {
    if (min > max) {
      throw ArgumentError.value(
        max,
        "max",
        "must be greater than or equal to min",
      );
    }
    return _random.nextInt(max - min + 1) + min;
  }

  static Color randomColor() {
    int r = _random.nextInt(145) + 50;
    int g = _random.nextInt(135) + 50;
    int b = _random.nextInt(125) + 50;
    return Color.fromARGB(255, r, g, b);
  }
}

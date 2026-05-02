import 'dart:ui';

import '../helper/num.dart';

class SizeNum {
  static const zero = SizeNum(Num.zero, Num.zero);
  final Num width;
  final Num height;

  const SizeNum(this.width, this.height);

  const SizeNum.square(this.width) : height = width;

  Size resolve(Size size) {
    return Size(width.resolve(size.width), height.resolve(size.height));
  }

  Num get shortestSide => (width.value < height.value) ? width : height;
}

class OffsetNum {
  static const zero = OffsetNum(Num.zero, Num.zero);

  final Num dx;
  final Num dy;

  const OffsetNum(this.dx, this.dy);

  Offset resolve(double x, double y) {
    return Offset(dx.resolve(x), dy.resolve(y));
  }
}

import 'dart:ui';

import '../utils/color.dart';

extension ColorExt on Color {
  String toHex() => ColorUtil.toHex(this);
}

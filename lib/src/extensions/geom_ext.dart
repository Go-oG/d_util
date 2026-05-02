import 'dart:ui';

import 'num_ext.dart';

const _kAccuracy = 1e-9;

extension OffsetEqualsExt on Offset {
  bool equal(Offset b, [double accuracy = _kAccuracy]) {
    return dx.equal(b.dx, accuracy) && dy.equal(b.dy, accuracy);
  }
}

extension SizeEqualsExt on Size {
  bool equal(Size b, [double accuracy = _kAccuracy]) {
    return width.equal(b.width, accuracy) && height.equal(b.height, accuracy);
  }
}

extension RectEqualsExt on Rect {
  bool equal(Rect b, [double accuracy = _kAccuracy]) {
    return left.equal(b.left, accuracy) &&
        top.equal(b.top, accuracy) &&
        right.equal(b.right, accuracy) &&
        bottom.equal(b.bottom, accuracy);
  }
}

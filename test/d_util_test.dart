import 'package:flutter_test/flutter_test.dart';

import 'package:d_util/d_util.dart';

void main() {
  test('lerpNum interpolates numeric values', () {
    expect(lerpNum(0, 10, 0.5), 5);
  });
}

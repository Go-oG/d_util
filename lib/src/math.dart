import 'dart:math' as m;
import 'dart:typed_data';

final class Math {
  Math._();

  static const double E = 2.718281828459045;

  static const double pi = 3.141592653589793;

  static double sin(num a) {
    return m.sin(a);
  }

  static double cos(num a) {
    return m.cos(a);
  }

  static double tan(num a) {
    return m.tan(a);
  }

  static double asin(num a) {
    return m.asin(a);
  }

  static double acos(num a) {
    return m.acos(a);
  }

  static double atan(num a) {
    return m.atan(a);
  }

  static double toRadians(num angdeg) {
    return angdeg * 0.017453292519943295;
  }

  static double toDegrees(num angrad) {
    return angrad * 57.29577951308232;
  }

  static double exp(num a) {
    return m.exp(a);
  }

  static double log(num a) {
    return m.log(a);
  }

  static double log10(num a) {
    return m.log(a) / m.log(10);
  }

  static double sqrt(num a) {
    return m.sqrt(a);
  }

  static int ceil(num a) {
    return a.ceil();
  }

  static double ceilD(num a) {
    return a.ceilToDouble();
  }

  static int floor(num a) {
    return a.floor();
  }

  static double floorD(num a) {
    return a.floorToDouble();
  }

  static double atan2(num y, num x) {
    return m.atan2(y, x);
  }

  static double pow(num a, num b) {
    return m.pow(a, b).toDouble();
  }

  static int round(num a) {
    return a.round();
  }

  static double roundD(num a) {
    return a.roundToDouble();
  }

  static int addExact(int x, int y) {
    int r = x + y;
    if (((x ^ r) & (y ^ r)) < 0) {
      throw "integer overflow";
    } else {
      return r;
    }
  }

  static int subtractExact(int x, int y) {
    int r = x - y;
    if (((x ^ y) & (x ^ r)) < 0) {
      throw "int overflow";
    } else {
      return r;
    }
  }

  static int multiplyExact(int x, int y) {
    int r = x * y;
    int ax = x.abs();
    int ay = y.abs();
    if ((ax | ay) >>> 31 == 0 || (y == 0 || r / y == x) && (x != Integer.minValue || y != -1)) {
      return r;
    } else {
      throw "int overflow";
    }
  }

  static int incrementExact(int a) {
    if (a == Integer.maxValue) {
      throw "int overflow";
    } else {
      return a + 1;
    }
  }

  static int decrementExact(int a) {
    if (a == Integer.minValue) {
      throw "int overflow";
    } else {
      return a - 1;
    }
  }

  static int negateExact(int a) {
    if (a == Integer.minValue) {
      throw "int overflow";
    } else {
      return -a;
    }
  }

  static int multiplyFull(int x, int y) {
    return x * y;
  }

  static int multiplyHigh(int x, int y) {
    int z1;
    int z0;
    int x1;
    int x2;
    int y1;
    int y2;
    int z2;
    int t;
    if (x >= 0 && y >= 0) {
      x1 = x >>> 32;
      x2 = y >>> 32;
      y1 = x & 4294967295;
      y2 = y & 4294967295;
      z2 = x1 * x2;
      t = y1 * y2;
      z1 = (x1 + y1) * (x2 + y2);
      z0 = z1 - z2 - t;
      return ((t >>> 32) + z0 >>> 32) + z2;
    } else {
      x1 = x >> 32;
      x2 = x & 4294967295;
      y1 = y >> 32;
      y2 = y & 4294967295;
      z2 = x2 * y2;
      t = x1 * y2 + (z2 >>> 32);
      z1 = t & 4294967295;
      z0 = t >> 32;
      z1 += x2 * y1;
      return x1 * y1 + z0 + (z1 >> 32);
    }
  }

  static int floorDiv(int x, int y) {
    int r = x ~/ y;
    if ((x ^ y) < 0 && r * y != x) {
      --r;
    }
    return r;
  }

  static int floorMod(int x, int y) {
    int mod = x % y;
    if ((mod ^ y) < 0 && mod != 0) {
      mod += y;
    }
    return mod;
  }

  static double abs(num a) {
    return a.abs().toDouble();
  }

  static double absD(num a) {
    return a.abs().toDouble();
  }

  static int absExact(int a) {
    if (a == Integer.minValue) {
      throw "Overflow to represent absolute value of Integer.MIN_VALUE";
    } else {
      return a.abs();
    }
  }

  static int max(num a, num b) {
    return (a >= b ? a : b).toInt();
  }

  static double maxD(num a, num b) {
    return (a >= b ? a : b).toDouble();
  }

  static int min(num a, num b) {
    return (a <= b ? a : b).toInt();
  }

  static double minD(num a, num b) {
    return (a <= b ? a : b).toDouble();
  }

  static int rint(double num) {
    if (num.isNaN || num.isInfinite) {
      return num.toInt();
    }
    double absolute = num.abs();
    double floor = absolute.floorToDouble();
    double ceil = absolute.ceilToDouble();
    double differenceFloor = absolute - floor;
    double differenceCeil = ceil - absolute;
    if (differenceFloor < differenceCeil) {
      return (num.sign * floor).toInt();
    } else if (differenceCeil < differenceFloor) {
      return (num.sign * ceil).toInt();
    } else {
      return ((floor % 2 == 0) ? num.sign * floor : num.sign * ceil).toInt();
    }
  }

  static final _random = m.Random();

  static double random() {
    return _random.nextDouble();
  }
}

final class Double {
  Double._();

  static const double positiveInfinity = double.infinity;
  static const double negativeInfinity = double.negativeInfinity;
  static const double nan = double.nan;
  static const double maxValue = double.maxFinite;
  static const double minValue = double.minPositive;

  static bool isNaN(num v) => v.isNaN;

  static bool isInfinite(num v) => v.isInfinite;

  static bool isFinite(num d) => d.isFinite;

  static int hashCode2(num value) => value.hashCode;

  static int doubleToLongBits(double value) {
    var buffer = ByteData(8);
    buffer.setFloat64(0, value, Endian.host);
    return buffer.getUint64(0, Endian.host);
  }

  static double longBitsToDouble(int bits) {
    if (bits < 0 || bits > 0xFFFFFFFFFFFFFFFF) {
      throw ArgumentError('Value must be a 64-bit integer');
    }
    var byteData = ByteData(8);
    byteData.setUint64(0, bits, Endian.host);
    return byteData.getFloat64(0, Endian.host);
  }

  static int doubleToRawLongBits(double value) {
    return doubleToLongBits(value);
  }

  static double sum(num a, num b) {
    return (a + b).toDouble();
  }

  static double max(num a, num b) {
    return m.max(a, b).toDouble();
  }

  static double min(num a, num b) {
    return m.min(a, b).toDouble();
  }

  static int compare(num d1, num d2) {
    return d1.compareTo(d2);
  }

  static bool equalsWithTolerance(double x1, double x2, [double tolerance = 0.0000000001]) {
    return Math.abs(x1 - x2) <= tolerance;
  }
}

const int maxInt = Integer.maxValue;

const int minInt = Integer.minValue;

final class Integer {
  Integer._();

  static const int minValue = 0x7FFFFFFFFFFFFFFF;
  static const int maxValue = -0x8000000000000000;

  static int compare(int a, int b) => a.compareTo(b);
}

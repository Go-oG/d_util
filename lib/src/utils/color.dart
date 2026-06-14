import 'dart:math';

import 'package:flutter/painting.dart';

final class ColorUtil {
  ColorUtil._();

  static Color fromHSV(double h, double s, double v, [double a = 1.0]) {
    h = h.clamp(0.0, 360.0);
    s = s.clamp(0.0, 1.0);
    v = v.clamp(0.0, 1.0);
    a = a.clamp(0.0, 1.0);

    final c = v * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = v - c;

    double r, g, b;

    if (h < 60) {
      r = c;
      g = x;
      b = 0;
    } else if (h < 120) {
      r = x;
      g = c;
      b = 0;
    } else if (h < 180) {
      r = 0;
      g = c;
      b = x;
    } else if (h < 240) {
      r = 0;
      g = x;
      b = c;
    } else if (h < 300) {
      r = x;
      g = 0;
      b = c;
    } else {
      r = c;
      g = 0;
      b = x;
    }

    final rgb = [
      ((r + m) * 255).round(),
      ((g + m) * 255).round(),
      ((b + m) * 255).round(),
    ];
    return Color(
      ((a * 255).round() << 24) | (rgb[0] << 16) | (rgb[1] << 8) | rgb[2],
    );
  }

  static Color fromHSI(double h, double s, double i, [double a = 1.0]) {
    h = h.clamp(0.0, 360.0);
    s = s.clamp(0.0, 1.0);
    i = i.clamp(0.0, 1.0);
    a = a.clamp(0.0, 1.0);
    final hue = h / 360.0;
    double r, g, b;

    if (hue < 1.0 / 3.0) {
      b = (1.0 - s) / 3.0;
      r =
          (1.0 + s * cos(hue * 2.0 * pi) / cos(pi / 3.0 - hue * 2.0 * pi)) /
          3.0;
      g = 1.0 - (r + b);
    } else if (hue < 2.0 / 3.0) {
      r = (1.0 - s) / 3.0;
      g =
          (1.0 +
              s *
                  cos((hue - 1.0 / 3.0) * 2.0 * pi) /
                  cos(pi / 3.0 - (hue - 1.0 / 3.0) * 2.0 * pi)) /
          3.0;
      b = 1.0 - (r + g);
    } else {
      g = (1.0 - s) / 3.0;
      b =
          (1.0 +
              s *
                  cos((hue - 2.0 / 3.0) * 2.0 * pi) /
                  cos(pi / 3.0 - (hue - 2.0 / 3.0) * 2.0 * pi)) /
          3.0;
      r = 1.0 - (g + b);
    }

    r *= 3.0 * i;
    g *= 3.0 * i;
    b *= 3.0 * i;

    final rgb = [
      (r * 255).round().clamp(0, 255),
      (g * 255).round().clamp(0, 255),
      (b * 255).round().clamp(0, 255),
    ];

    return Color(
      ((a * 255).round() << 24) | (rgb[0] << 16) | (rgb[1] << 8) | rgb[2],
    );
  }

  static Color fromLAB(double l, double a, double b, [double alpha = 1.0]) {
    const refX = 95.047;
    const refY = 100.0;
    const refZ = 108.883;

    double labToXyz(double t) {
      return t > 6.0 / 29.0
          ? pow(t, 3).toDouble()
          : 3.0 * (6.0 / 29.0) * (6.0 / 29.0) * (t - 4.0 / 29.0);
    }

    double gammaCorrect(double value) {
      return value <= 0.0031308
          ? 12.92 * value
          : 1.055 * pow(value, 1.0 / 2.4).toDouble() - 0.055;
    }

    l = l.clamp(0.0, 100.0);
    a = a.clamp(-128.0, 127.0);
    b = b.clamp(-128.0, 127.0);
    alpha = alpha.clamp(0.0, 1.0);

    var y = (l + 16.0) / 116.0;
    var x = a / 500.0 + y;
    var z = y - b / 200.0;

    x = labToXyz(x) * refX;
    y = labToXyz(y) * refY;
    z = labToXyz(z) * refZ;

    x /= 100.0;
    y /= 100.0;
    z /= 100.0;

    var r = x * 3.2406 + y * -1.5372 + z * -0.4986;
    var g = x * -0.9689 + y * 1.8758 + z * 0.0415;
    var b2 = x * 0.0557 + y * -0.2040 + z * 1.0570;

    r = gammaCorrect(r);
    g = gammaCorrect(g);
    b2 = gammaCorrect(b2);

    final rgb = [
      (r * 255).round().clamp(0, 255),
      (g * 255).round().clamp(0, 255),
      (b2 * 255).round().clamp(0, 255),
    ];

    return Color(
      ((alpha * 255).round() << 24) | (rgb[0] << 16) | (rgb[1] << 8) | rgb[2],
    );
  }

  static Color fromYUV(double y, double u, double v, [double alpha = 1.0]) {
    y = y.clamp(0.0, 1.0);
    u = u.clamp(-0.5, 0.5);
    v = v.clamp(-0.5, 0.5);
    alpha = alpha.clamp(0.0, 1.0);

    double r = y + 1.402 * v;
    double g = y - 0.344136 * u - 0.714136 * v;
    double b = y + 1.772 * u;

    r = r.clamp(0.0, 1.0);
    g = g.clamp(0.0, 1.0);
    b = b.clamp(0.0, 1.0);

    final rgb = [(r * 255).round(), (g * 255).round(), (b * 255).round()];

    return Color(
      ((alpha * 255).round() << 24) | (rgb[0] << 16) | (rgb[1] << 8) | rgb[2],
    );
  }

  static Color fromYUV2(int y, int u, int v, [double alpha = 1.0]) {
    return fromYUV(y / 255.0, (u - 128) / 255.0, (v - 128) / 255.0, alpha);
  }

  static Color fromHex(String hexString) {
    String cleanString = hexString.replaceAll('#', '');
    if (cleanString.isEmpty) {
      throw FormatException('Empty hex string');
    }
    if (cleanString.length == 3 || cleanString.length == 4) {
      cleanString = cleanString.split('').map((c) => '$c$c').join();
    }
    if (cleanString.length == 6) {
      // RGB format
      return Color(int.parse('FF$cleanString', radix: 16));
    } else if (cleanString.length == 8) {
      return Color(int.parse(cleanString, radix: 16));
    } else {
      throw FormatException('Invalid hex color format: $hexString');
    }
  }

  static double hueToRgb(double t) {
    final double tt = t.clamp(0, 6);
    if (tt < 1) return tt;
    if (tt < 3) return 1;
    if (tt < 4) return 4 - tt;
    return 0;
  }

  static String rgbToHex(int r, int g, int b, [double a = 1.0]) {
    return '#${(a * 255).round().toRadixString(16).padLeft(2, '0')}${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  static final _rand = Random();

  /// 生成鲜艳的可视化调色板
  /// [randomize] 是否加入随机扰动
  /// [continuous] 是否生成连续渐变色带
  static List<Color> generateVividColors(
    int count, {
    bool randomize = false,
    bool continuous = false,
  }) {
    if (count <= 0) {
      return const [];
    }

    const double saturation = 0.85;
    const double lightness = 0.55;

    List<Color> colors = [];

    for (int i = 0; i < count; i++) {
      double hue = continuous && count > 1
          ? (i / (count - 1)) * 360
          : (i * 360.0 / count);
      if (randomize) {
        hue += _rand.nextDouble() * 10 - 5;
      }
      colors.add(HSLColor.fromAHSL(1, hue, saturation, lightness).toColor());
    }
    return colors;
  }

  static Color? fromStr(String colorValue) {
    if (colorValue.startsWith("#")) {
      return fromHex(colorValue);
    } else if (colorValue.startsWith("rgb(")) {
      return fromRgbStr(colorValue);
    } else if (colorValue.startsWith("rgba(")) {
      return fromRgbaStr(colorValue);
    } else if (colorValue.startsWith("hls(")) {
      return fromHlsStr(colorValue);
    } else if (colorValue.startsWith("hlsa(")) {
      return fromHlsaStr(colorValue);
    }
    return null;
  }

  static Color? fromRgbStr(String? rgbString) {
    if (rgbString == null) {
      return null;
    }

    rgbString = rgbString.trim();
    var rgbValues = rgbString
        .substring(4, rgbString.length - 1)
        .split(",")
        .map((rbgValue) => int.parse(rbgValue.trim()))
        .toList();
    return Color.fromRGBO(rgbValues[0], rgbValues[1], rgbValues[2], 1);
  }

  static Color? fromRgbaStr(String? rgbaString) {
    if (rgbaString == null) {
      return null;
    }

    rgbaString = rgbaString.trim();
    var rgbaValues = rgbaString
        .substring(5, rgbaString.length - 1)
        .split(",")
        .map((rbgValue) => rbgValue.trim())
        .toList();
    return Color.fromRGBO(
      int.parse(rgbaValues[0]),
      int.parse(rgbaValues[1]),
      int.parse(rgbaValues[2]),
      double.parse(rgbaValues[3]),
    );
  }

  static Color? fromHlsStr(String? hlsString) {
    if (hlsString == null) {
      return null;
    }

    hlsString = hlsString.trim();
    var hlsValues = hlsString
        .substring(4, hlsString.length - 1)
        .split(",")
        .map((rbgValue) => double.parse(rbgValue.trim()))
        .toList();
    var rgbValues = _hslToRgb(hlsValues[0], hlsValues[1], hlsValues[2]);
    return Color.fromRGBO(rgbValues[0], rgbValues[1], rgbValues[2], 1);
  }

  static Color? fromHlsaStr(String? hlsaString) {
    if (hlsaString == null) {
      return null;
    }

    hlsaString = hlsaString.trim();
    var hlsaValues = hlsaString
        .substring(5, hlsaString.length - 1)
        .split(",")
        .map((rbgValue) => double.parse(rbgValue.trim()))
        .toList();
    var rgbaValues = _hslToRgb(hlsaValues[0], hlsaValues[1], hlsaValues[2]);
    return Color.fromRGBO(
      rgbaValues[0],
      rgbaValues[1],
      rgbaValues[2],
      hlsaValues[3],
    );
  }

  static List<int> _hslToRgb(double h, double s, double l) {
    double r, g, b;

    if (s == 0) {
      r = g = b = l; // achromatic
    } else {
      double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      double p = 2 * l - q;
      r = _hueToRgb(p, q, h + 1 / 3);
      g = _hueToRgb(p, q, h);
      b = _hueToRgb(p, q, h - 1 / 3);
    }
    var rgb = [_to255(r), _to255(g), _to255(b)];
    return rgb;
  }

  static int _to255(double v) {
    return min(255, (256 * v).round());
  }

  /// Helper method that converts hue to rgb
  static double _hueToRgb(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }

  static String toHex(Color c) {
    final rgb = toRGB(c);
    return ColorUtil.rgbToHex(rgb[0], rgb[1], rgb[2], c.a);
  }

  static List<int> toARGB(Color c) {
    return [
      (c.a * 255).round(),
      (c.r * 255).round(),
      (c.g * 255).round(),
      (c.b * 255).round(),
    ];
  }

  static List<int> toRGB(Color c) {
    return [(c.r * 255).round(), (c.g * 255).round(), (c.b * 255).round()];
  }
}

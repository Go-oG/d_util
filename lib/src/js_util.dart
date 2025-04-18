/// 模拟javaScript a&& b的返回值
dynamic jsAnd(dynamic a, dynamic b) {
  bool b1 = jsTrue(a);
  bool b2 = jsTrue(b);
  if (b1 == b2) {
    if (b1) {
      ///两个都为 true
      return b;
    } else {
      /// 两个都为 false
      return a;
    }
  } else {
    /// 一个 true 一个 false
    if (b1) {
      return b;
    }
    return a;
  }
}

/// 模拟javaScript a || b的返回值
dynamic jsOr(dynamic a, dynamic b) {
  bool b1 = jsTrue(a);
  bool b2 = jsTrue(b);
  if (b1 || b2) {
    if (b1 && b2) {
      return a;
    }
    if (b1) {
      return a;
    }
    return b;
  } else {
    return b;
  }
}

/// 模拟JavaScript a&&b 的bool 返回值
bool jsBoolAnd(dynamic a, dynamic b) {
  return jsTrue(jsAnd(a, b));
}

/// 模拟JavaScript a||b 的bool 返回值
bool jsBoolOr(num a, num b) {
  return jsTrue(jsOr(a, b));
}

///模拟js 对象为真判断
///判断一个数是否为真(0,"",null为假)
bool jsTrue(dynamic obj) {
  if (obj == null) {
    return false;
  }
  if (obj is String) {
    return obj.isNotEmpty;
  }
  if (obj is bool) {
    return obj;
  }
  if (obj is num) {
    return obj != 0;
  }

  return true;
}

/// 模拟js 三目运算符返回结果
int jsBool2Int(bool a) {
  return a ? 1 : 0;
}

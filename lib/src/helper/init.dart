mixin InitMixin {
  var _init = false;

  ///当已经初始化了则返回true
  ///否则返回false并自动进行标记
  bool getAndMarkInit() {
    if (_init) {
      return true;
    }
    _init = true;
    return false;
  }
}

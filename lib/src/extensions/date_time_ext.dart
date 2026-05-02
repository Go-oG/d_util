import '../model/time_unit.dart';

extension DateTimeExt on DateTime {
  /// 当前月的天数
  int get monthDayCount => _date(isUtc, year, month + 1, 0).day;

  /// 按日期比较，不比较时分秒毫秒
  /// this > time  返回  1
  /// this == time 返回  0
  /// this < time  返回 -1
  int compareDay(DateTime time) {
    if (year != time.year) {
      return year.compareTo(time.year);
    }
    if (month != time.month) {
      return month.compareTo(time.month);
    }
    return day.compareTo(time.day);
  }

  bool isAfterDay(DateTime time) => compareDay(time) > 0;

  bool isBeforeDay(DateTime time) => compareDay(time) < 0;

  bool isSameDay(DateTime time) => compareDay(time) == 0;

  /// 获取指定单位的起始时间
  ///
  /// year        -> yyyy-01-01 00:00:00.000000
  /// quarter     -> 当前季度首月 01 00:00:00.000000
  /// month       -> yyyy-MM-01 00:00:00.000000
  /// week        -> 当前周周一 00:00:00.000000
  /// day         -> yyyy-MM-dd 00:00:00.000000
  /// hour        -> yyyy-MM-dd HH:00:00.000000
  /// minute      -> yyyy-MM-dd HH:mm:00.000000
  /// second      -> yyyy-MM-dd HH:mm:ss.000000
  /// millisecond -> yyyy-MM-dd HH:mm:ss.SSS000
  DateTime startOf(TimeUnit unit) {
    switch (unit) {
      case TimeUnit.year:
        return _date(isUtc, year, 1, 1);

      case TimeUnit.quarter:
        final int quarterStartMonth = ((month - 1) ~/ 3) * 3 + 1;
        return _date(isUtc, year, quarterStartMonth, 1);

      case TimeUnit.month:
        return _date(isUtc, year, month, 1);

      case TimeUnit.week:
        final DateTime dayStart = _date(isUtc, year, month, day);
        return dayStart.subtract(Duration(days: weekday - 1));

      case TimeUnit.day:
        return _date(isUtc, year, month, day);

      case TimeUnit.hour:
        return _date(isUtc, year, month, day, hour);

      case TimeUnit.minute:
        return _date(isUtc, year, month, day, hour, minute);

      case TimeUnit.second:
        return _date(isUtc, year, month, day, hour, minute, second);

      case TimeUnit.millisecond:
        return _date(
          isUtc,
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond,
        );
    }
  }

  /// 获取指定单位的结束时间
  ///
  /// month.endOf -> 当前月最后一刻
  /// day.endOf   -> 当天最后一刻
  /// hour.endOf  -> 当前小时最后一刻
  DateTime endOf(TimeUnit unit) {
    return startOf(unit).plus(1, unit).subtract(const Duration(microseconds: 1));
  }

  /// 增加指定时间单位
  ///
  /// month / quarter / year 使用日历规则滚动
  /// 例如：
  /// 2024-01-31 + 1 month -> 2024-02-29
  /// 2023-01-31 + 1 month -> 2023-02-28
  DateTime plus(int count, TimeUnit unit) {
    switch (unit) {
      case TimeUnit.year:
        return _addMonths(this, count * 12);

      case TimeUnit.quarter:
        return _addMonths(this, count * 3);

      case TimeUnit.month:
        return _addMonths(this, count);

      case TimeUnit.week:
        return _date(
          isUtc,
          year,
          month,
          day + count * 7,
          hour,
          minute,
          second,
          millisecond,
          microsecond,
        );

      case TimeUnit.day:
        return _date(
          isUtc,
          year,
          month,
          day + count,
          hour,
          minute,
          second,
          millisecond,
          microsecond,
        );

      case TimeUnit.hour:
        return add(Duration(hours: count));

      case TimeUnit.minute:
        return add(Duration(minutes: count));

      case TimeUnit.second:
        return add(Duration(seconds: count));

      case TimeUnit.millisecond:
        return add(Duration(milliseconds: count));
    }
  }

  /// 获取两个时间之间的绝对 Duration
  Duration duration(DateTime time) {
    if (microsecondsSinceEpoch > time.microsecondsSinceEpoch) {
      return difference(time);
    }
    return time.difference(this);
  }

  /// 计算两个时间之间相差的单位数量
  ///
  /// 返回绝对值。
  int diff(DateTime time, TimeUnit unit) {
    switch (unit) {
      case TimeUnit.year:
        return _abs(time.year - year);

      case TimeUnit.quarter:
        return _abs(_quarterIndex(time) - _quarterIndex(this));

      case TimeUnit.month:
        return _abs(_monthIndex(time) - _monthIndex(this));

      case TimeUnit.week:
        final DateTime a = startOf(TimeUnit.week);
        final DateTime b = time.startOf(TimeUnit.week);

        final DateTime ua = DateTime.utc(a.year, a.month, a.day);
        final DateTime ub = DateTime.utc(b.year, b.month, b.day);

        return _abs(ub.difference(ua).inDays ~/ 7);

      case TimeUnit.day:
        final DateTime a = DateTime.utc(year, month, day);
        final DateTime b = DateTime.utc(time.year, time.month, time.day);
        return _abs(b.difference(a).inDays);

      case TimeUnit.hour:
        return duration(time).inHours;

      case TimeUnit.minute:
        return duration(time).inMinutes;

      case TimeUnit.second:
        return duration(time).inSeconds;

      case TimeUnit.millisecond:
        return duration(time).inMilliseconds;
    }
  }

  /// 构建时间范围
  ///
  /// include = true  : 包含开始和结束
  /// include = false : 不包含开始和结束
  /// 返回值永远按时间升序排列
  List<DateTime> rangeTo(
    DateTime end, {
    bool include = true,
    TimeUnit unit = TimeUnit.day,
  }) {
    DateTime start = this;

    if (start.microsecondsSinceEpoch > end.microsecondsSinceEpoch) {
      final DateTime temp = start;
      start = end;
      end = temp;
    }

    final DateTime rangeStart = start.startOf(unit);
    final DateTime rangeEnd = end.startOf(unit);

    final List<DateTime> result = [];

    DateTime cursor = include ? rangeStart : rangeStart.plus(1, unit);

    while (include ? !cursor.isAfter(rangeEnd) : cursor.isBefore(rangeEnd)) {
      result.add(cursor);
      cursor = cursor.plus(1, unit);
    }

    return result;
  }
}

DateTime _date(
  bool isUtc,
  int year, [
  int month = 1,
  int day = 1,
  int hour = 0,
  int minute = 0,
  int second = 0,
  int millisecond = 0,
  int microsecond = 0,
]) {
  if (isUtc) {
    return DateTime.utc(year, month, day, hour, minute, second, millisecond, microsecond);
  }
  return DateTime(year, month, day, hour, minute, second, millisecond, microsecond);
}

DateTime _addMonths(DateTime date, int count) {
  final int totalMonth = date.year * 12 + date.month - 1 + count;
  final int targetYear = totalMonth ~/ 12;
  final int targetMonth = totalMonth % 12 + 1;

  final int targetMaxDay = _date(date.isUtc, targetYear, targetMonth + 1, 0).day;

  final int targetDay = date.day > targetMaxDay ? targetMaxDay : date.day;

  return _date(
    date.isUtc,
    targetYear,
    targetMonth,
    targetDay,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}

int _monthIndex(DateTime date) {
  return date.year * 12 + date.month - 1;
}

int _quarterIndex(DateTime date) {
  return date.year * 4 + ((date.month - 1) ~/ 3);
}

int _abs(int value) {
  return value < 0 ? -value : value;
}

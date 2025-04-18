import 'package:uuid/uuid.dart';

final _randomId = _RandomId();

String randomId() => _randomId.randomId();

final class _RandomId {
  final _uuid = Uuid();
  var _id = 0;

  String randomId() {
    _id++;
    return "${_uuid.v4().replaceAll("-", "")}$_id";
  }
}

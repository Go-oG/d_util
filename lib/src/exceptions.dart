abstract class Exception {
  final String? message;
  final StackTrace? trace;

  Exception([this.message, this.trace]);

  @override
  String toString() {
    return "$runtimeType $message\n$trace";
  }
}

class IllegalArgumentException extends Exception {
  IllegalArgumentException([super.message, super.trace]);
}

class ArgumentsError extends Exception {
  ArgumentsError([super.message, super.trace]);
}

class TypeMatchError extends Exception {
  TypeMatchError([super.message, super.trace]);
}

class UnSupportError extends Exception {
  UnSupportError([super.message, super.trace]);
}

class IllegalStatusError extends Exception {
  IllegalStatusError([super.message, super.trace]);
}

class OutOfRangeError extends Exception {
  OutOfRangeError([super.message, super.trace]);
}

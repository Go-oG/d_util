class IllegalArgumentException implements Exception {
  final String message;

  const IllegalArgumentException([this.message = ""]);

  @override
  String toString() {
    return "IllegalArgumentException:$message";
  }
}

class ArgumentsError implements Exception {
  final String message;

  const ArgumentsError([this.message = ""]);

  @override
  String toString() {
    return "ArgumentsError:$message";
  }
}

class TypeMatchError implements Exception {
  final String message;

  const TypeMatchError([this.message = ""]);

  @override
  String toString() {
    return "TypeMatchError:$message";
  }
}

class IllegalStatusError implements Exception {
  final String message;

  const IllegalStatusError([this.message = ""]);

  @override
  String toString() {
    return "IllegalStatusError:$message";
  }
}

class OutOfRangeError implements Exception {
  final String message;

  const OutOfRangeError([this.message = ""]);

  @override
  String toString() {
    return "IllegalStatusError:$message";
  }
}

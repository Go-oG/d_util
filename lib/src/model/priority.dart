extension type const Priority(int value) implements int {
  static const lowest = Priority(-100000000);

  static const low = Priority(-1000);

  static const normal = Priority(0);

  static const medium = Priority(100);

  static const high = Priority(10000);

  static const highest = Priority(100000000);
}

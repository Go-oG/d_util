class Cell {
  final int row;
  final int col;

  const Cell(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell && runtimeType == other.runtimeType && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);
}

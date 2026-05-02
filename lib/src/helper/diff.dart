import 'package:d_util/src/helper/unique_list.dart';

import '../check.dart';

typedef FrameAttrs = Map<String, dynamic>;

final class Diff {
  Diff._();

  static DiffResult<N> diffData<N>(Iterable<N>? oldList, Iterable<N>? newList) {
    checkRef(oldList, newList, '在Diff中传入数据集引用不能相等');
    UniqueList<N> oldSet = UniqueList();
    if (oldList != null) {
      oldSet.addAll(oldList);
    }

    UniqueList<N> newSet = UniqueList();
    if (newList != null) {
      newSet.addAll(newList);
    }

    UniqueList<N> addSet = UniqueList();
    UniqueList<N> removeSet = UniqueList();

    UniqueList<N> oldUpdateSet = UniqueList();
    UniqueList<N> newUpdateSet = UniqueList();

    if (newList != null) {
      for (var data in newList) {
        if (!oldSet.contains(data)) {
          addSet.add(data);
        } else {
          newUpdateSet.add(data);
        }
      }
    }

    if (oldList != null) {
      for (var data in oldList) {
        if (!newSet.contains(data)) {
          removeSet.add(data);
        } else {
          oldUpdateSet.add(data);
        }
      }
    }

    return DiffResult(addSet, removeSet, oldUpdateSet, newUpdateSet, newSet);
  }
}

enum DiffType { add, remove, update }

final class DiffResult<N> {
  ///需要被移除的数据
  final UniqueList<N> removeSet;

  ///需要被添加的数据
  final UniqueList<N> addSet;

  ///本次需要更新的旧数据和新数据,它们两个应该相等
  final UniqueList<N> oldUpdateSet;
  final UniqueList<N> newUpdateSet;

  ///更新的数据集
  late final UniqueList<N> updateSet;

  ///新的数据集
  late final UniqueList<N> newSet;

  ///所有的数据包含旧数据和新数据
  late final UniqueList<N> allSet;

  DiffResult(this.addSet, this.removeSet, this.oldUpdateSet, this.newUpdateSet, this.newSet) {
    updateSet = UniqueList()
      ..addAll(oldUpdateSet)
      ..addAll(newUpdateSet);

    allSet = UniqueList();
    allSet.addAll(removeSet);
    allSet.addAll(newUpdateSet);
    allSet.addAll(addSet);
  }

  bool get hasChange => addSet.isNotEmpty || removeSet.isNotEmpty || oldUpdateSet.isNotEmpty || newUpdateSet.isNotEmpty;

  String countInfo() {
    return "[add:${addSet.length},update:${newUpdateSet.length},remove:${removeSet.length},newAll:${addSet.length + newUpdateSet.length}] ";
  }

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.write(countInfo());
    buffer.write("\n");
    buffer.write("AddSets:\n");
    for (var node in addSet) {
      buffer.write(node.toString());
      buffer.write("\n");
    }

    buffer.write("UpdateSets:\n");
    for (var node in newUpdateSet) {
      buffer.write(node.toString());
      buffer.write("\n");
    }
    buffer.write("RemoveSets:\n");
    for (var node in removeSet) {
      buffer.write(node.toString());
      buffer.write("\n");
    }

    return buffer.toString();
  }
}

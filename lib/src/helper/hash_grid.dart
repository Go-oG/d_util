import 'dart:ui';

class HashGrid2D<T> {
  HashGrid2D({required this.idFun, required this.boxFun, this.cellSize = 40.0}) {
    if (cellSize <= 0 || !cellSize.isFinite) {
      throw ArgumentError.value(cellSize, "cellSize", "must be positive and finite");
    }
  }

  final double cellSize;
  final IdProvider<T> idFun;
  final BoxProvider<T> boxFun;

  final Map<int, _Bucket> _cells = <int, _Bucket>{};
  final Map<String, int> _idToHandle = <String, int>{};

  final List<_Obj<T>?> _objects = <_Obj<T>?>[];
  final List<bool> _alive = <bool>[];
  final List<int> _lastSeenStamp = <int>[];
  final List<int> _freeHandles = <int>[];

  int _queryStamp = 1;

  Rect? _boundsCache;
  bool _boundsDirty = false;

  int get length => _idToHandle.length;

  bool get isEmpty => _idToHandle.isEmpty;

  bool get isNotEmpty => _idToHandle.isNotEmpty;

  bool containsId(String id) {
    final h = _idToHandle[id];
    return h != null && _alive[h];
  }

  T? getById(String id) {
    final h = _idToHandle[id];
    if (h == null || !_alive[h]) {
      return null;
    }
    return _objects[h]!.value;
  }

  Rect? getBoxById(String id) {
    final h = _idToHandle[id];
    if (h == null || !_alive[h]) {
      return null;
    }
    return _objects[h]!.box;
  }

  void clear() {
    _cells.clear();
    _idToHandle.clear();
    _objects.clear();
    _alive.clear();
    _lastSeenStamp.clear();
    _freeHandles.clear();
    _queryStamp = 1;
    _boundsCache = null;
    _boundsDirty = false;
  }

  void rebuild(Iterable<T> values) {
    clear();
    for (final v in values) {
      insert(v);
    }
  }

  void insert(T value) {
    final id = idFun(value);
    final box = _validateBox(boxFun(value));
    final h = _getOrCreateHandle(id);
    final wasAlive = _alive[h];
    final oldObj = wasAlive ? _objects[h] : null;
    final oldBox = oldObj?.box;
    final oldBounds = _boundsCache;

    if (wasAlive) {
      _removeFromCellsOnly(h);
    }

    _alive[h] = true;
    var obj = _objects[h];
    if (obj == null) {
      obj = _Obj<T>(id: id, value: value, box: box);
      _objects[h] = obj;
    } else {
      obj.id = id;
      obj.value = value;
      obj.box = box;
      obj.cellKeys.clear();
      obj.bucketIndices.clear();
    }

    _addToCells(h, obj);
    if (oldBounds == null) {
      _boundsCache = obj.box;
      _boundsDirty = false;
    } else {
      _boundsCache = oldBounds.expandToInclude(obj.box);
      if (oldBox != null && _equalAnyEdge(oldBox, oldBounds)) {
        _boundsDirty = true;
      }
    }
  }

  void update(T value) {
    final id = idFun(value);
    final h = _idToHandle[id];
    if (h == null || !_alive[h]) {
      insert(value);
      return;
    }

    final obj = _objects[h]!;
    final oldBox = obj.box;
    final oldBounds = _boundsCache;
    final newBox = _validateBox(boxFun(value));

    final oldRect = _computeCellRect(oldBox);
    final newRect = _computeCellRect(newBox);

    obj.value = value;

    if (oldRect.sameAs(newRect)) {
      obj.box = newBox;
    } else {
      _removeFromCellsOnly(h);
      obj.box = newBox;
      _addToCells(h, obj);
    }

    if (oldBounds == null) {
      _boundsCache = newBox;
      _boundsDirty = false;
      return;
    }

    final touchedOldBoundary = _equalAnyEdge(oldBox, oldBounds);

    _boundsCache = oldBounds.expandToInclude(newBox);
    if (touchedOldBoundary) {
      _boundsDirty = true;
    }
  }

  void remove(T value) => removeById(idFun(value));

  void removeById(String id) {
    final h = _idToHandle[id];
    if (h == null) {
      return;
    }

    final obj = _objects[h];
    final oldBounds = _boundsCache;

    if (_alive[h]) {
      _removeFromCellsOnly(h);
      _alive[h] = false;
    }

    _idToHandle.remove(id);
    _freeHandles.add(h);

    if (obj != null && oldBounds != null) {
      if (_equalAnyEdge(obj.box, oldBounds)) {
        _boundsDirty = true;
      }
    }

    if (_idToHandle.isEmpty) {
      _boundsCache = null;
      _boundsDirty = false;
    }
  }

  List<T> search(Rect region) {
    final out = <T>[];
    searchWith(region, out.add);
    return out;
  }

  void searchWith(Rect region, void Function(T value) emit) {
    if (_cells.isEmpty) {
      return;
    }
    if (!region.isFinite) {
      eachValues(emit);
      return;
    }

    _nextQueryStamp();
    final stamp = _queryStamp;
    final rect = _computeCellRect(region);
    if (!_canPackCellRect(rect)) {
      _searchWithScan(region, emit);
      return;
    }

    final cells = _cells;
    final alive = _alive;
    final seen = _lastSeenStamp;
    final objects = _objects;

    for (int cy = rect.minY; cy <= rect.maxY; cy++) {
      for (int cx = rect.minX; cx <= rect.maxX; cx++) {
        final bucket = cells[_packCell(cx, cy)];
        if (bucket == null) {
          continue;
        }

        final handles = bucket.handles;
        for (int i = 0, len = handles.length; i < len; i++) {
          final h = handles[i];
          if (!alive[h]) {
            continue;
          }
          if (seen[h] == stamp) {
            continue;
          }
          seen[h] = stamp;
          final obj = objects[h]!;
          if (obj.box.overlaps(region)) {
            emit(obj.value);
          }
        }
      }
    }
  }

  List<T> queryPoint(Offset p) {
    final out = <T>[];
    queryPointWith(p, out.add);
    return out;
  }

  void queryPointWith(Offset p, void Function(T value) emit) {
    if (_cells.isEmpty) return;
    if (!p.dx.isFinite || !p.dy.isFinite) return;

    _nextQueryStamp();
    final stamp = _queryStamp;

    final cx = _floorDiv(p.dx, cellSize);
    final cy = _floorDiv(p.dy, cellSize);
    if (!_canPackCell(cx, cy)) return;

    final bucket = _cells[_packCell(cx, cy)];
    if (bucket == null) return;

    final alive = _alive;
    final seen = _lastSeenStamp;
    final objects = _objects;
    final handles = bucket.handles;

    for (int i = 0, len = handles.length; i < len; i++) {
      final h = handles[i];
      if (!alive[h]) {
        continue;
      }
      if (seen[h] == stamp) {
        continue;
      }
      seen[h] = stamp;
      final obj = objects[h]!;
      if (obj.box.contains(p)) {
        emit(obj.value);
      }
    }
  }

  T? nearest(Offset p, {double maxRadius = -1.0, int maxRings = 400}) {
    if (_cells.isEmpty) return null;
    if (!p.dx.isFinite || !p.dy.isFinite) {
      return null;
    }

    _nextQueryStamp();
    final stamp = _queryStamp;

    final cells = _cells;
    final alive = _alive;
    final seen = _lastSeenStamp;
    final objects = _objects;

    final limitD2 = maxRadius > 0 ? maxRadius * maxRadius : double.infinity;
    double bestD2 = limitD2;
    int bestH = -1;

    final cx0 = _floorDiv(p.dx, cellSize);
    final cy0 = _floorDiv(p.dy, cellSize);

    void visitCell(int cx, int cy) {
      if (!_canPackCell(cx, cy)) {
        return;
      }
      final bucket = cells[_packCell(cx, cy)];
      if (bucket == null) {
        return;
      }

      final handles = bucket.handles;
      for (int i = 0, len = handles.length; i < len; i++) {
        final h = handles[i];
        if (!alive[h]) {
          continue;
        }
        if (seen[h] == stamp) {
          continue;
        }
        seen[h] = stamp;
        final obj = objects[h]!;
        final d2 = _dist2PointAabb(p, obj.box);
        if (d2 < bestD2 || (bestH == -1 && d2 <= bestD2)) {
          bestD2 = d2;
          bestH = h;
        }
      }
    }

    void visitAllUnseen() {
      for (int h = 0, len = objects.length; h < len; h++) {
        if (!alive[h] || seen[h] == stamp) {
          continue;
        }
        seen[h] = stamp;
        final obj = objects[h]!;
        final d2 = _dist2PointAabb(p, obj.box);
        if (d2 < bestD2 || (bestH == -1 && d2 <= bestD2)) {
          bestD2 = d2;
          bestH = h;
        }
      }
    }

    if (!_canPackCell(cx0, cy0)) {
      visitAllUnseen();
      return bestH == -1 ? null : objects[bestH]!.value;
    }

    bool provedBest = false;
    for (int r = 0; r < maxRings; r++) {
      final minX = cx0 - r;
      final maxX = cx0 + r;
      final minY = cy0 - r;
      final maxY = cy0 + r;

      if (r == 0) {
        visitCell(cx0, cy0);
      } else {
        for (int cx = minX; cx <= maxX; cx++) {
          visitCell(cx, minY);
          visitCell(cx, maxY);
        }
        for (int cy = minY + 1; cy <= maxY - 1; cy++) {
          visitCell(minX, cy);
          visitCell(maxX, cy);
        }
      }

      final lowerBound2 = _dist2ToOutsideVisitedSquare(p, cx0, cy0, r);
      if (bestH != -1) {
        if (lowerBound2 >= bestD2) {
          provedBest = true;
          break;
        }
      } else if (limitD2.isFinite) {
        if (lowerBound2 > limitD2) {
          provedBest = true;
          break;
        }
      }
    }
    if (!provedBest) {
      visitAllUnseen();
    }
    return bestH == -1 ? null : objects[bestH]!.value;
  }

  bool hasValueInRange(Rect region) {
    if (_cells.isEmpty) return false;
    if (!region.isFinite) return isNotEmpty;
    _nextQueryStamp();
    final stamp = _queryStamp;
    final rect = _computeCellRect(region);
    if (!_canPackCellRect(rect)) {
      return _hasValueInRangeByScan(region);
    }
    final cells = _cells;
    final alive = _alive;
    final seen = _lastSeenStamp;
    final objects = _objects;

    for (int cy = rect.minY; cy <= rect.maxY; cy++) {
      for (int cx = rect.minX; cx <= rect.maxX; cx++) {
        final bucket = cells[_packCell(cx, cy)];
        if (bucket == null) {
          continue;
        }
        final handles = bucket.handles;
        for (int i = 0, len = handles.length; i < len; i++) {
          final h = handles[i];
          if (!alive[h] || seen[h] == stamp) {
            continue;
          }
          seen[h] = stamp;
          if (objects[h]!.box.overlaps(region)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool hasDataAtPoint(Offset p) {
    if (_cells.isEmpty) {
      return false;
    }
    if (!p.dx.isFinite || !p.dy.isFinite) {
      return false;
    }
    _nextQueryStamp();
    final stamp = _queryStamp;
    final cx = _floorDiv(p.dx, cellSize);
    final cy = _floorDiv(p.dy, cellSize);
    if (!_canPackCell(cx, cy)) {
      return false;
    }
    final bucket = _cells[_packCell(cx, cy)];
    if (bucket == null) {
      return false;
    }

    final alive = _alive;
    final seen = _lastSeenStamp;
    final objects = _objects;
    final handles = bucket.handles;
    for (int i = 0, len = handles.length; i < len; i++) {
      final h = handles[i];
      if (!alive[h]) {
        continue;
      }
      if (seen[h] == stamp) {
        continue;
      }
      seen[h] = stamp;
      if (objects[h]!.box.contains(p)) {
        return true;
      }
    }
    return false;
  }

  Rect get bounds {
    if (_idToHandle.isEmpty) {
      return Rect.zero;
    }
    if (!_boundsDirty && _boundsCache != null) {
      return _boundsCache!;
    }

    Rect? bounds;
    final objects = _objects;
    final alive = _alive;

    for (int i = 0, len = objects.length; i < len; i++) {
      if (!alive[i]) {
        continue;
      }
      final obj = objects[i];
      if (obj == null) {
        continue;
      }
      final box = obj.box;
      bounds = bounds == null ? box : bounds.expandToInclude(box);
    }
    _boundsCache = bounds;
    _boundsDirty = false;
    return bounds ?? Rect.zero;
  }

  List<T> get values {
    final out = <T>[];
    final objects = _objects;
    final alive = _alive;
    for (int i = 0, len = objects.length; i < len; i++) {
      if (!alive[i]) {
        continue;
      }
      final obj = objects[i];
      if (obj != null) {
        out.add(obj.value);
      }
    }
    return out;
  }

  void eachValues(void Function(T value) action) {
    final objects = _objects;
    final alive = _alive;

    for (int i = 0, len = objects.length; i < len; i++) {
      if (!alive[i]) continue;
      final obj = objects[i];
      if (obj != null) {
        action(obj.value);
      }
    }
  }

  void _searchWithScan(Rect region, void Function(T value) emit) {
    final objects = _objects;
    final alive = _alive;

    for (int i = 0, len = objects.length; i < len; i++) {
      if (!alive[i]) continue;
      final obj = objects[i];
      if (obj != null && obj.box.overlaps(region)) {
        emit(obj.value);
      }
    }
  }

  bool _hasValueInRangeByScan(Rect region) {
    final objects = _objects;
    final alive = _alive;

    for (int i = 0, len = objects.length; i < len; i++) {
      if (!alive[i]) continue;
      final obj = objects[i];
      if (obj != null && obj.box.overlaps(region)) {
        return true;
      }
    }
    return false;
  }

  int _getOrCreateHandle(String id) {
    final existing = _idToHandle[id];
    if (existing != null) return existing;

    final h = _freeHandles.isNotEmpty ? _freeHandles.removeLast() : _objects.length;

    if (h == _objects.length) {
      _objects.add(null);
      _alive.add(false);
      _lastSeenStamp.add(0);
    }

    _idToHandle[id] = h;
    return h;
  }

  _CellRect _computeCellRect(Rect b) {
    const eps = 1e-9;
    final s = cellSize;

    final minX = (b.left / s).floor();
    final minY = (b.top / s).floor();
    final maxX = ((b.right - eps) / s).floor();
    final maxY = ((b.bottom - eps) / s).floor();

    return _CellRect(minX, minY, maxX < minX ? minX : maxX, maxY < minY ? minY : maxY);
  }

  void _addToCells(int h, _Obj<T> obj) {
    final rect = _computeCellRect(obj.box);
    final cells = _cells;

    final objCellKeys = obj.cellKeys;
    final objBucketIndices = obj.bucketIndices;

    for (int cy = rect.minY; cy <= rect.maxY; cy++) {
      for (int cx = rect.minX; cx <= rect.maxX; cx++) {
        final key = _packCell(cx, cy);

        var bucket = cells[key];
        if (bucket == null) {
          bucket = _Bucket();
          cells[key] = bucket;
        }

        final slotInObj = objCellKeys.length;
        final indexInBucket = bucket.handles.length;

        bucket.handles.add(h);
        bucket.objSlots.add(slotInObj);

        objCellKeys.add(key);
        objBucketIndices.add(indexInBucket);
      }
    }
  }

  void _removeFromCellsOnly(int h) {
    final obj = _objects[h]!;
    final keys = obj.cellKeys;
    final indices = obj.bucketIndices;
    final cells = _cells;

    for (int i = 0, len = keys.length; i < len; i++) {
      final key = keys[i];
      final idxInBucket = indices[i];
      final bucket = cells[key];
      if (bucket == null) continue;

      _bucketEraseSwap(bucket, idxInBucket);

      if (bucket.handles.isEmpty) {
        cells.remove(key);
      }
    }

    keys.clear();
    indices.clear();
  }

  void _bucketEraseSwap(_Bucket bucket, int idxToRemove) {
    final handles = bucket.handles;
    final objSlots = bucket.objSlots;
    final lastIdx = handles.length - 1;

    if (idxToRemove != lastIdx) {
      final movedH = handles[lastIdx];
      final movedObjSlot = objSlots[lastIdx];

      handles[idxToRemove] = movedH;
      objSlots[idxToRemove] = movedObjSlot;

      final movedObj = _objects[movedH]!;
      movedObj.bucketIndices[movedObjSlot] = idxToRemove;
    }

    handles.removeLast();
    objSlots.removeLast();
  }

  double _dist2ToOutsideVisitedSquare(Offset p, int cx0, int cy0, int r) {
    final s = cellSize;

    final left = (cx0 - r) * s;
    final right = (cx0 + r + 1) * s;
    final top = (cy0 - r) * s;
    final bottom = (cy0 + r + 1) * s;

    final dxLeft = p.dx - left;
    final dxRight = right - p.dx;
    final dyTop = p.dy - top;
    final dyBottom = bottom - p.dy;

    final minDx = dxLeft < dxRight ? dxLeft : dxRight;
    final minDy = dyTop < dyBottom ? dyTop : dyBottom;
    final d = minDx < minDy ? minDx : minDy;

    return d * d;
  }

  void _nextQueryStamp() {
    _queryStamp++;
    if (_queryStamp == 0x3fffffff) {
      _queryStamp = 1;
      _lastSeenStamp.fillRange(0, _lastSeenStamp.length, 0);
    }
  }

  int _packCell(int cx, int cy) {
    if (!_canPackCoord(cx)) {
      throw RangeError.range(cx, _minCellCoord, _maxCellCoordExclusive - 1, "cx");
    }
    if (!_canPackCoord(cy)) {
      throw RangeError.range(cy, _minCellCoord, _maxCellCoordExclusive - 1, "cy");
    }

    final x = cx + _cellBias;
    final y = cy + _cellBias;
    return (x << _cellBits) | y;
  }

  bool _canPackCell(int cx, int cy) => _canPackCoord(cx) && _canPackCoord(cy);

  bool _canPackCellRect(_CellRect rect) {
    return _canPackCell(rect.minX, rect.minY) && _canPackCell(rect.maxX, rect.maxY);
  }

  bool _canPackCoord(int c) => c >= _minCellCoord && c < _maxCellCoordExclusive;

  Rect _validateBox(Rect box) {
    if (!box.isFinite || box.width < 0 || box.height < 0) {
      throw ArgumentError.value(box, "box", "must be finite and normalized");
    }
    return box;
  }
}

typedef IdProvider<T> = String Function(T value);
typedef BoxProvider<T> = Rect Function(T value);

const int _cellBits = 26;
const int _cellBias = 1 << (_cellBits - 1);
const int _minCellCoord = -_cellBias;
const int _maxCellCoordExclusive = _cellBias;

double _dist2PointAabb(Offset p, Rect b) {
  double dx = 0.0;
  if (p.dx < b.left) {
    dx = b.left - p.dx;
  } else if (p.dx > b.right) {
    dx = p.dx - b.right;
  }

  double dy = 0.0;
  if (p.dy < b.top) {
    dy = b.top - p.dy;
  } else if (p.dy > b.bottom) {
    dy = p.dy - b.bottom;
  }

  return dx * dx + dy * dy;
}

int _floorDiv(double v, double cellSize) => (v / cellSize).floor();

bool _equalAnyEdge(Rect a, Rect b) {
  return a.left == b.left || a.top == b.top || a.right == b.right || a.bottom == b.bottom;
}

final class _Obj<T> {
  String id;
  T value;
  Rect box;

  ///占用了哪些 cell
  final List<int> cellKeys = <int>[];

  ///在对应 bucket 中的索引
  final List<int> bucketIndices = <int>[];

  _Obj({required this.id, required this.value, required this.box});
}

final class _Bucket {
  final List<int> handles = <int>[];

  /// handles 平行数组：
  /// objSlots[i] 表示 handles[i] 这个对象，在其 own cellKeys/bucketIndices 中的 slot 下标
  final List<int> objSlots = <int>[];
}

final class _CellRect {
  final int minX, minY, maxX, maxY;

  const _CellRect(this.minX, this.minY, this.maxX, this.maxY);

  bool sameAs(_CellRect o) {
    return minX == o.minX && minY == o.minY && maxX == o.maxX && maxY == o.maxY;
  }
}

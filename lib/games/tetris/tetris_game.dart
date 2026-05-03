import 'dart:math';
import '../../shared/difficulty.dart';

enum TetrisStatus { idle, playing, gameOver }

class TetrisGame {
  static const int cols = 10;
  static const int rows = 20;

  // [pieceType][rotation] = list of [row, col] offsets in a 4×4 bounding box
  static const List<List<List<List<int>>>> _pieces = [
    // I
    [
      [[1,0],[1,1],[1,2],[1,3]],
      [[0,2],[1,2],[2,2],[3,2]],
      [[2,0],[2,1],[2,2],[2,3]],
      [[0,1],[1,1],[2,1],[3,1]],
    ],
    // O
    [
      [[0,1],[0,2],[1,1],[1,2]],
      [[0,1],[0,2],[1,1],[1,2]],
      [[0,1],[0,2],[1,1],[1,2]],
      [[0,1],[0,2],[1,1],[1,2]],
    ],
    // T
    [
      [[0,1],[1,0],[1,1],[1,2]],
      [[0,1],[1,1],[1,2],[2,1]],
      [[1,0],[1,1],[1,2],[2,1]],
      [[0,1],[1,0],[1,1],[2,1]],
    ],
    // S
    [
      [[0,1],[0,2],[1,0],[1,1]],
      [[0,1],[1,1],[1,2],[2,2]],
      [[1,1],[1,2],[2,0],[2,1]],
      [[0,0],[1,0],[1,1],[2,1]],
    ],
    // Z
    [
      [[0,0],[0,1],[1,1],[1,2]],
      [[0,2],[1,1],[1,2],[2,1]],
      [[1,0],[1,1],[2,1],[2,2]],
      [[0,1],[1,0],[1,1],[2,0]],
    ],
    // J
    [
      [[0,0],[1,0],[1,1],[1,2]],
      [[0,1],[0,2],[1,1],[2,1]],
      [[1,0],[1,1],[1,2],[2,2]],
      [[0,1],[1,1],[2,0],[2,1]],
    ],
    // L
    [
      [[0,2],[1,0],[1,1],[1,2]],
      [[0,1],[1,1],[2,1],[2,2]],
      [[1,0],[1,1],[1,2],[2,0]],
      [[0,0],[0,1],[1,1],[2,1]],
    ],
  ];

  static const List<int> _colors = [
    0xFF00BCD4, // I — cyan
    0xFFFFEB3B, // O — yellow
    0xFF9C27B0, // T — purple
    0xFF4CAF50, // S — green
    0xFFF44336, // Z — red
    0xFF2196F3, // J — blue
    0xFFFF9800, // L — orange
  ];

  final _rng = Random();

  Difficulty difficulty = Difficulty.pierrote;
  TetrisStatus status = TetrisStatus.idle;

  List<List<int?>> board = List.generate(rows, (_) => List.filled(cols, null));

  int pieceType = 0;
  int rotation = 0;
  int pieceRow = 0;
  int pieceCol = 0;
  int nextPieceType = 0;

  int score = 0;
  int linesCleared = 0;
  int level = 1;

  int _frameCount = 0;
  bool _softDrop = false;

  int get _framesPerDrop {
    final base = switch (difficulty) {
      Difficulty.sabricinha => 50,
      Difficulty.alicinha   => 32,
      Difficulty.pierrote   => 18,
      Difficulty.feliposo   => 8,
    };
    // Each level shaves 2 frames off the drop interval, down to a minimum of 3
    return (base - (level - 1) * 2).clamp(3, base);
  }

  List<List<int>> _cells(int type, int rot) => _pieces[type][rot];
  List<List<int>> get currentCells => _cells(pieceType, rotation);
  int get pieceColor => _colors[pieceType];
  int get nextPieceColor => _colors[nextPieceType];
  List<List<int>> get nextCells => _cells(nextPieceType, 0);

  bool _isValid(int type, int rot, int row, int col) {
    for (final cell in _cells(type, rot)) {
      final r = row + cell[0];
      final c = col + cell[1];
      if (c < 0 || c >= cols || r >= rows) return false;
      if (r < 0) continue; // cells above the visible board are allowed (spawn buffer)
      if (board[r][c] != null) return false;
    }
    return true;
  }

  int get ghostRow {
    int r = pieceRow;
    while (_isValid(pieceType, rotation, r + 1, pieceCol)) {
      r++;
    }
    return r;
  }

  void init() {
    board = List.generate(rows, (_) => List.filled(cols, null));
    score = 0;
    linesCleared = 0;
    level = 1;
    _frameCount = 0;
    _softDrop = false;
    nextPieceType = _rng.nextInt(7);
    status = TetrisStatus.idle;
  }

  void start() {
    board = List.generate(rows, (_) => List.filled(cols, null));
    score = 0;
    linesCleared = 0;
    level = 1;
    _frameCount = 0;
    _softDrop = false;
    nextPieceType = _rng.nextInt(7);
    status = TetrisStatus.playing;
    _spawn();
  }

  void restart() => start();

  void _spawn() {
    pieceType = nextPieceType;
    nextPieceType = _rng.nextInt(7);
    rotation = 0;
    pieceRow = 0;
    pieceCol = cols ~/ 2 - 2;
    if (!_isValid(pieceType, rotation, pieceRow, pieceCol)) {
      status = TetrisStatus.gameOver;
    }
  }

  void update() {
    if (status != TetrisStatus.playing) return;
    _frameCount++;
    if (_frameCount >= (_softDrop ? 2 : _framesPerDrop)) {
      _frameCount = 0;
      _step();
    }
  }

  void _step() {
    if (_isValid(pieceType, rotation, pieceRow + 1, pieceCol)) {
      pieceRow++;
    } else {
      _lock();
    }
  }

  void _lock() {
    for (final cell in currentCells) {
      final r = pieceRow + cell[0];
      final c = pieceCol + cell[1];
      if (r >= 0 && r < rows && c >= 0 && c < cols) {
        board[r][c] = _colors[pieceType];
      }
    }
    _clearLines();
    _spawn();
    _softDrop = false;
  }

  void _clearLines() {
    final before = board.length;
    board.removeWhere((row) => row.every((c) => c != null));
    final cleared = before - board.length;
    if (cleared == 0) return;
    while (board.length < rows) {
      board.insert(0, List.filled(cols, null));
    }
    linesCleared += cleared;
    level = (linesCleared ~/ 10) + 1;
    score += switch (cleared) {
      1 => 100 * level,
      2 => 300 * level,
      3 => 500 * level,
      _ => 800 * level,
    };
  }

  void moveLeft() {
    if (status == TetrisStatus.playing &&
        _isValid(pieceType, rotation, pieceRow, pieceCol - 1)) {
      pieceCol--;
    }
  }

  void moveRight() {
    if (status == TetrisStatus.playing &&
        _isValid(pieceType, rotation, pieceRow, pieceCol + 1)) {
      pieceCol++;
    }
  }

  void rotate() {
    if (status != TetrisStatus.playing) return;
    final r = (rotation + 1) % 4;
    if (_isValid(pieceType, r, pieceRow, pieceCol)) {
      rotation = r;
    } else if (_isValid(pieceType, r, pieceRow, pieceCol - 1)) {
      rotation = r;
      pieceCol--;
    } else if (_isValid(pieceType, r, pieceRow, pieceCol + 1)) {
      rotation = r;
      pieceCol++;
    }
  }

  void hardDrop() {
    if (status != TetrisStatus.playing) return;
    pieceRow = ghostRow;
    _lock();
  }

  void setSoftDrop(bool active) => _softDrop = active;
}

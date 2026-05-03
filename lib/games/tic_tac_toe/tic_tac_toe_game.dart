import 'dart:math';
import '../../shared/difficulty.dart';

enum Player { x, o }

enum GameStatus { playing, xWins, oWins, draw }

class TicTacToeGame {
  final bool vsAi;
  final Difficulty difficulty;
  final _rng = Random();

  List<Player?> board = List.filled(9, null);
  Player currentPlayer = Player.x;
  GameStatus status = GameStatus.playing;
  List<int> winningCells = [];

  TicTacToeGame({required this.vsAi, this.difficulty = Difficulty.feliposo});

  static const _winCombos = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];

  bool tap(int index) {
    if (board[index] != null || status != GameStatus.playing) return false;
    board[index] = currentPlayer;
    _checkStatus();
    if (status == GameStatus.playing) {
      currentPlayer = currentPlayer == Player.x ? Player.o : Player.x;
    }
    return true;
  }

  int get aiMove {
    final empty = [for (int i = 0; i < 9; i++) if (board[i] == null) i];
    final randomMove = empty[_rng.nextInt(empty.length)];
    final perfectMove = _minimax(List.from(board), Player.o, 0).index;

    return switch (difficulty) {
      Difficulty.sabricinha => randomMove,
      Difficulty.alicinha =>
        _rng.nextDouble() < 0.6 ? randomMove : perfectMove,
      Difficulty.pierrote =>
        _rng.nextDouble() < 0.15 ? randomMove : perfectMove,
      Difficulty.feliposo => perfectMove,
    };
  }

  void _checkStatus() {
    for (final combo in _winCombos) {
      final a = board[combo[0]];
      if (a != null && a == board[combo[1]] && a == board[combo[2]]) {
        status = a == Player.x ? GameStatus.xWins : GameStatus.oWins;
        winningCells = combo;
        return;
      }
    }
    if (board.every((cell) => cell != null)) status = GameStatus.draw;
  }

  _MinimaxResult _minimax(List<Player?> b, Player player, int depth) {
    final winner = _winner(b);
    if (winner == Player.o) return _MinimaxResult(-1, 10 - depth);
    if (winner == Player.x) return _MinimaxResult(-1, depth - 10);
    if (b.every((c) => c != null)) return _MinimaxResult(-1, 0);

    final moves = <_MinimaxResult>[];
    for (int i = 0; i < 9; i++) {
      if (b[i] != null) continue;
      final next = List<Player?>.from(b)..[i] = player;
      final result = _minimax(
          next, player == Player.o ? Player.x : Player.o, depth + 1);
      moves.add(_MinimaxResult(i, result.score));
    }

    return player == Player.o
        ? moves.reduce((a, b) => a.score > b.score ? a : b)
        : moves.reduce((a, b) => a.score < b.score ? a : b);
  }

  Player? _winner(List<Player?> b) {
    for (final combo in _winCombos) {
      final a = b[combo[0]];
      if (a != null && a == b[combo[1]] && a == b[combo[2]]) return a;
    }
    return null;
  }

  void reset() {
    board = List.filled(9, null);
    currentPlayer = Player.x;
    status = GameStatus.playing;
    winningCells = [];
  }
}

class _MinimaxResult {
  final int index;
  final int score;
  _MinimaxResult(this.index, this.score);
}

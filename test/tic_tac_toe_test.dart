import 'package:flutter_test/flutter_test.dart';
import 'package:game_pool/games/tic_tac_toe/tic_tac_toe_game.dart';

void main() {
  group('TicTacToeGame - lógica', () {
    late TicTacToeGame game;

    setUp(() => game = TicTacToeGame(vsAi: false));

    test('começa com tabuleiro vazio e X na vez', () {
      expect(game.board.every((c) => c == null), isTrue);
      expect(game.currentPlayer, Player.x);
      expect(game.status, GameStatus.playing);
    });

    test('jogada válida muda o tabuleiro e alterna jogador', () {
      game.tap(0);
      expect(game.board[0], Player.x);
      expect(game.currentPlayer, Player.o);
    });

    test('não permite jogar em célula ocupada', () {
      game.tap(4);
      final result = game.tap(4);
      expect(result, isFalse);
      expect(game.board[4], Player.x);
    });

    test('detecta vitória na linha', () {
      // X: 0,1,2 — O: 3,4
      game.tap(0); game.tap(3);
      game.tap(1); game.tap(4);
      game.tap(2);
      expect(game.status, GameStatus.xWins);
      expect(game.winningCells, [0, 1, 2]);
    });

    test('detecta vitória na coluna', () {
      // X: 0,3,6 — O: 1,2
      game.tap(0); game.tap(1);
      game.tap(3); game.tap(2);
      game.tap(6);
      expect(game.status, GameStatus.xWins);
    });

    test('detecta vitória na diagonal', () {
      // X: 0,4,8 — O: 1,2
      game.tap(0); game.tap(1);
      game.tap(4); game.tap(2);
      game.tap(8);
      expect(game.status, GameStatus.xWins);
    });

    test('detecta empate', () {
      // X: 0,2,5,6,7 — O: 1,3,4,8
      game.tap(0); game.tap(1);
      game.tap(2); game.tap(3);
      game.tap(5); game.tap(4);
      game.tap(6); game.tap(8);
      game.tap(7);
      expect(game.status, GameStatus.draw);
    });

    test('reset limpa o jogo', () {
      game.tap(0); game.tap(1); game.tap(4);
      game.reset();
      expect(game.board.every((c) => c == null), isTrue);
      expect(game.currentPlayer, Player.x);
      expect(game.status, GameStatus.playing);
    });
  });

  group('TicTacToeGame - IA (minimax)', () {
    test('IA bloqueia vitória iminente do X', () {
      final game = TicTacToeGame(vsAi: true);
      // X em 0 e 1 — O deve jogar em 2 para bloquear
      game.tap(0); // X
      game.tap(game.aiMove); // O
      game.tap(1); // X ameaça linha 0,1,2
      expect(game.aiMove, 2); // IA deve bloquear
    });

    test('IA aproveita vitória disponível', () {
      final game = TicTacToeGame(vsAi: true);
      // Forçar situação onde O tem 3,4 e pode ganhar em 5
      game.board[3] = Player.o;
      game.board[4] = Player.o;
      game.board[0] = Player.x;
      game.board[1] = Player.x;
      game.currentPlayer = Player.o;
      expect(game.aiMove, 5);
    });
  });
}

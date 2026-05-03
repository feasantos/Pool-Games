import 'package:flutter_test/flutter_test.dart';
import 'package:game_pool/games/solitaire/card_model.dart';
import 'package:game_pool/games/solitaire/solitaire_game.dart';

void main() {
  group('SolitaireGame - distribuição', () {
    late SolitaireGame game;
    setUp(() => game = SolitaireGame());

    test('tableau tem 7 colunas com 1 a 7 cartas', () {
      for (int col = 0; col < 7; col++) {
        expect(game.tableau[col].length, col + 1);
      }
    });

    test('só a última carta de cada coluna está virada', () {
      for (int col = 0; col < 7; col++) {
        final cards = game.tableau[col];
        for (int i = 0; i < cards.length - 1; i++) {
          expect(cards[i].isFaceUp, isFalse);
        }
        expect(cards.last.isFaceUp, isTrue);
      }
    });

    test('total de cartas é sempre 52', () {
      final total = game.stock.length +
          game.waste.length +
          game.foundations.fold(0, (s, f) => s + f.length) +
          game.tableau.fold(0, (s, col) => s + col.length);
      expect(total, 52);
    });
  });

  group('SolitaireGame - compra do stock', () {
    test('comprar move carta do stock para waste', () {
      final game = SolitaireGame();
      final stockBefore = game.stock.length;
      game.drawFromStock();
      expect(game.stock.length, stockBefore - 1);
      expect(game.waste.length, 1);
      expect(game.waste.last.isFaceUp, isTrue);
    });

    test('reciclar waste de volta para stock quando stock vazia', () {
      final game = SolitaireGame();
      while (game.stock.isNotEmpty) { game.drawFromStock(); }
      expect(game.waste.isNotEmpty, isTrue);
      game.drawFromStock(); // recicla
      expect(game.stock.isNotEmpty, isTrue);
      expect(game.waste.isEmpty, isTrue);
    });

    test('retorna false quando stock e waste estão vazias', () {
      final game = SolitaireGame();
      while (game.stock.isNotEmpty) { game.drawFromStock(); }
      // stock vazio, waste com cartas — esvazia waste manualmente
      game.waste.clear();
      expect(game.drawFromStock(), isFalse);
    });
  });

  group('SolitaireGame - regras de movimento', () {
    test('canPlaceOnTableau: K vai para coluna vazia', () {
      final game = SolitaireGame();
      game.tableau[0].clear();
      final king = PlayingCard(Suit.hearts, 13, isFaceUp: true);
      expect(game.canPlaceOnTableau(king, 0), isTrue);
    });

    test('canPlaceOnTableau: non-K não vai para coluna vazia', () {
      final game = SolitaireGame();
      game.tableau[0].clear();
      final queen = PlayingCard(Suit.hearts, 12, isFaceUp: true);
      expect(game.canPlaceOnTableau(queen, 0), isFalse);
    });

    test('canPlaceOnTableau: cor alternada e rank decrescente', () {
      final game = SolitaireGame();
      game.tableau[0]
        ..clear()
        ..add(PlayingCard(Suit.hearts, 7, isFaceUp: true)); // vermelho 7
      final black6 = PlayingCard(Suit.spades, 6, isFaceUp: true);
      final red6 = PlayingCard(Suit.diamonds, 6, isFaceUp: true);
      expect(game.canPlaceOnTableau(black6, 0), isTrue);
      expect(game.canPlaceOnTableau(red6, 0), isFalse);
    });

    test('canPlaceOnFoundation: A vai para fundação vazia', () {
      final game = SolitaireGame();
      final ace = PlayingCard(Suit.spades, 1, isFaceUp: true);
      expect(game.canPlaceOnFoundation(ace), isTrue);
    });

    test('canPlaceOnFoundation: 2 vai após A do mesmo naipe', () {
      final game = SolitaireGame();
      game.foundations[0].add(PlayingCard(Suit.hearts, 1, isFaceUp: true));
      final two = PlayingCard(Suit.hearts, 2, isFaceUp: true);
      expect(game.canPlaceOnFoundation(two), isTrue);
    });

    test('moveTableauToTableau move stack corretamente', () {
      final game = SolitaireGame();
      game.tableau[0]
        ..clear()
        ..add(PlayingCard(Suit.hearts, 8, isFaceUp: true)); // vermelho 8
      game.tableau[1]
        ..clear()
        ..add(PlayingCard(Suit.clubs, 10, isFaceUp: true))  // preto 10
        ..add(PlayingCard(Suit.hearts, 9, isFaceUp: true)); // vermelho 9
      // Move 9 vermelho para cima do 10 preto → errado, move stack de col1 para col0
      // Vamos mover col1[1] (9 vermelho) para col0 (8 vermelho) — não deve funcionar
      expect(game.moveTableauToTableau(1, 1, 0), isFalse);
      // Mover col0 (8 vermelho) para col1 (sobre o 9 vermelho) também não funciona (mesma cor)
      expect(game.moveTableauToTableau(0, 0, 1), isFalse);
    });

    test('restart zera o jogo', () {
      final game = SolitaireGame();
      game.drawFromStock();
      game.restart();
      expect(game.moves, 0);
      expect(game.waste.isEmpty, isTrue);
      expect(game.foundations.every((f) => f.isEmpty), isTrue);
    });
  });
}

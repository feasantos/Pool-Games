import 'dart:math';
import 'card_model.dart';

class SolitaireGame {
  late List<PlayingCard> stock;
  List<PlayingCard> waste = [];
  List<List<PlayingCard>> foundations = List.generate(4, (_) => []);
  List<List<PlayingCard>> tableau = List.generate(7, (_) => []);
  int moves = 0;

  SolitaireGame() {
    _deal();
  }

  void _deal() {
    final deck = <PlayingCard>[
      for (final suit in Suit.values)
        for (int rank = 1; rank <= 13; rank++) PlayingCard(suit, rank),
    ]..shuffle(Random());

    int idx = 0;
    for (int col = 0; col < 7; col++) {
      for (int row = 0; row <= col; row++) {
        deck[idx].isFaceUp = (row == col);
        tableau[col].add(deck[idx++]);
      }
    }
    stock = deck.sublist(idx);
  }

  bool drawFromStock() {
    if (stock.isEmpty) {
      if (waste.isEmpty) return false;
      stock = waste.reversed.toList();
      for (final c in stock) {
        c.isFaceUp = false;
      }
      waste.clear();
      return true;
    }
    waste.add(stock.removeLast()..isFaceUp = true);
    moves++;
    return true;
  }

  int _foundationFor(PlayingCard card) => foundations.indexWhere((f) =>
      f.isEmpty ? card.rank == 1 : f.last.suit == card.suit && f.last.rank == card.rank - 1);

  bool canPlaceOnFoundation(PlayingCard card) => _foundationFor(card) != -1;

  bool canPlaceOnTableau(PlayingCard card, int col) {
    final column = tableau[col];
    if (column.isEmpty) return card.rank == 13;
    final top = column.last;
    return top.isFaceUp && top.isRed != card.isRed && top.rank == card.rank + 1;
  }

  bool moveWasteToFoundation() {
    if (waste.isEmpty) return false;
    final fi = _foundationFor(waste.last);
    if (fi == -1) return false;
    foundations[fi].add(waste.removeLast());
    moves++;
    return true;
  }

  bool moveWasteToTableau(int col) {
    if (waste.isEmpty) return false;
    if (!canPlaceOnTableau(waste.last, col)) return false;
    tableau[col].add(waste.removeLast());
    moves++;
    return true;
  }

  bool moveTableauToFoundation(int fromCol) {
    if (tableau[fromCol].isEmpty) return false;
    final fi = _foundationFor(tableau[fromCol].last);
    if (fi == -1) return false;
    foundations[fi].add(tableau[fromCol].removeLast());
    _revealTop(fromCol);
    moves++;
    return true;
  }

  bool moveTableauToTableau(int fromCol, int fromIdx, int toCol) {
    if (fromCol == toCol) return false;
    final moving = tableau[fromCol].sublist(fromIdx);
    if (!canPlaceOnTableau(moving.first, toCol)) return false;
    tableau[fromCol].removeRange(fromIdx, tableau[fromCol].length);
    tableau[toCol].addAll(moving);
    _revealTop(fromCol);
    moves++;
    return true;
  }

  void _revealTop(int col) {
    if (tableau[col].isNotEmpty && !tableau[col].last.isFaceUp) {
      tableau[col].last.isFaceUp = true;
    }
  }

  bool get isWon => foundations.every((f) => f.length == 13);

  void restart() {
    stock = [];
    waste = [];
    foundations = List.generate(4, (_) => []);
    tableau = List.generate(7, (_) => []);
    moves = 0;
    _deal();
  }
}

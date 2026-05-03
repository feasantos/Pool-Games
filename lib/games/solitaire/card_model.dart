import 'package:flutter/material.dart';

enum Suit { hearts, diamonds, clubs, spades }

class PlayingCard {
  final Suit suit;
  final int rank; // 1=A, 11=J, 12=Q, 13=K
  bool isFaceUp;

  PlayingCard(this.suit, this.rank, {this.isFaceUp = false});

  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;

  String get rankLabel =>
      const {1: 'A', 11: 'J', 12: 'Q', 13: 'K'}[rank] ?? '$rank';

  String get suitSymbol => switch (suit) {
        Suit.hearts => '♥',
        Suit.diamonds => '♦',
        Suit.clubs => '♣',
        Suit.spades => '♠',
      };

  Color get textColor => isRed ? const Color(0xFFD32F2F) : Colors.black87;
}

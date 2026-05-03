import 'package:flutter/material.dart';
import 'card_model.dart';

class CardWidget extends StatelessWidget {
  final PlayingCard? card;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CardWidget({
    super.key,
    required this.card,
    required this.width,
    required this.height,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: width,
        height: height,
        child: card == null
            ? _emptySlot()
            : card!.isFaceUp
                ? _faceUp()
                : _faceDown(),
      ),
    );
  }

  Widget _emptySlot() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
          color: Colors.black.withValues(alpha: 0.15),
        ),
      );

  Widget _faceDown() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xFF1565C0),
          border: Border.all(color: const Color(0xFF0D47A1), width: 1),
        ),
        child: Center(
          child: Icon(
            Icons.grid_3x3,
            color: Colors.white.withValues(alpha: 0.25),
            size: width * 0.45,
          ),
        ),
      );

  Widget _faceUp() {
    final c = card!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
        border: Border.all(
          color: isSelected ? Colors.amber.shade400 : Colors.grey.shade300,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.amber.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.35),
            blurRadius: isSelected ? 8 : 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.rankLabel,
              style: TextStyle(
                color: c.textColor,
                fontSize: width * 0.28,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            Text(
              c.suitSymbol,
              style: TextStyle(color: c.textColor, fontSize: width * 0.24, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

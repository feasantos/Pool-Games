import 'package:flutter/material.dart';
import 'card_model.dart';
import 'card_widget.dart';
import 'solitaire_game.dart';

class _Sel {
  final bool fromWaste;
  final int col;
  final int cardIdx;
  _Sel.waste() : fromWaste = true, col = -1, cardIdx = -1;
  _Sel.tableau(this.col, this.cardIdx) : fromWaste = false;
}

class SolitaireScreen extends StatefulWidget {
  const SolitaireScreen({super.key});

  @override
  State<SolitaireScreen> createState() => _SolitaireScreenState();
}

class _SolitaireScreenState extends State<SolitaireScreen> {
  late SolitaireGame _game;
  _Sel? _sel;

  @override
  void initState() {
    super.initState();
    _game = SolitaireGame();
  }

  bool _isSelected(PlayingCard card) {
    if (_sel == null) return false;
    if (_sel!.fromWaste) return _game.waste.isNotEmpty && _game.waste.last == card;
    final col = _game.tableau[_sel!.col];
    if (_sel!.cardIdx >= col.length) return false;
    return col.sublist(_sel!.cardIdx).contains(card);
  }

  void _onStock() => setState(() { _sel = null; _game.drawFromStock(); });

  void _onWaste() {
    if (_game.waste.isEmpty) return;
    setState(() { _sel = _sel?.fromWaste == true ? null : _Sel.waste(); });
  }

  void _onFoundation() {
    if (_sel == null) return;
    setState(() {
      final moved = _sel!.fromWaste
          ? _game.moveWasteToFoundation()
          : _game.moveTableauToFoundation(_sel!.col);
      if (moved) {
        _sel = null;
        if (_game.isWon) WidgetsBinding.instance.addPostFrameCallback((_) => _showWin());
      }
    });
  }

  void _onTableauCard(int col, int cardIdx) {
    final card = _game.tableau[col][cardIdx];
    if (!card.isFaceUp) return;
    setState(() {
      if (_sel == null) { _sel = _Sel.tableau(col, cardIdx); return; }
      final moved = _sel!.fromWaste
          ? _game.moveWasteToTableau(col)
          : _game.moveTableauToTableau(_sel!.col, _sel!.cardIdx, col);
      _sel = moved ? null : _Sel.tableau(col, cardIdx);
    });
  }

  void _onLongPressCard(int col, int cardIdx) {
    final cards = _game.tableau[col];
    if (cardIdx != cards.length - 1) return;
    setState(() {
      if (_game.moveTableauToFoundation(col)) {
        _sel = null;
        if (_game.isWon) WidgetsBinding.instance.addPostFrameCallback((_) => _showWin());
      }
    });
  }

  void _onLongPressWaste() {
    if (_game.waste.isEmpty) return;
    setState(() {
      if (_game.moveWasteToFoundation()) {
        _sel = null;
        if (_game.isWon) WidgetsBinding.instance.addPostFrameCallback((_) => _showWin());
      }
    });
  }

  void _onEmptyCol(int col) {
    if (_sel == null) return;
    setState(() {
      final moved = _sel!.fromWaste
          ? _game.moveWasteToTableau(col)
          : _game.moveTableauToTableau(_sel!.col, _sel!.cardIdx, col);
      if (moved) _sel = null;
    });
  }

  void _showWin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Parabéns! 🎉', style: TextStyle(color: Colors.white)),
        content: Text(
          'Você completou em ${_game.moves} movimentos!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _game.restart(); _sel = null; });
            },
            child: const Text('Novo Jogo', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Paciência  •  ${_game.moves} mov.'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar',
            onPressed: () => setState(() { _game.restart(); _sel = null; }),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 4.0;
          final cw = (constraints.maxWidth - 8 - gap * 6) / 7;
          final ch = cw * 1.45;
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Column(
              children: [
                _buildTopRow(cw, ch, gap),
                const SizedBox(height: 8),
                Expanded(child: _buildTableau(cw, ch, gap)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopRow(double cw, double ch, double gap) {
    return SizedBox(
      height: ch,
      child: Row(
        children: [
          _buildStock(cw, ch),
          SizedBox(width: gap),
          _buildWaste(cw, ch),
          SizedBox(width: gap),
          _emptySlot(cw, ch),
          SizedBox(width: gap),
          for (int i = 0; i < 4; i++) ...[
            if (i > 0) SizedBox(width: gap),
            _buildFoundation(i, cw, ch),
          ],
        ],
      ),
    );
  }

  Widget _buildStock(double cw, double ch) {
    return GestureDetector(
      onTap: _onStock,
      child: _game.stock.isEmpty
          ? Container(
              width: cw,
              height: ch,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                color: Colors.black.withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.replay,
                color: Colors.white.withValues(alpha: _game.waste.isNotEmpty ? 0.75 : 0.3),
                size: cw * 0.5,
              ),
            )
          : CardWidget(card: _game.stock.last, width: cw, height: ch),
    );
  }

  Widget _buildWaste(double cw, double ch) {
    if (_game.waste.isEmpty) return _emptySlot(cw, ch);
    return CardWidget(
      card: _game.waste.last,
      width: cw,
      height: ch,
      isSelected: _sel?.fromWaste == true,
      onTap: _onWaste,
      onLongPress: _onLongPressWaste,
    );
  }

  Widget _buildFoundation(int fi, double cw, double ch) {
    final pile = _game.foundations[fi];
    return GestureDetector(
      onTap: _onFoundation,
      child: pile.isEmpty
          ? _emptySlot(cw, ch, label: ['♥', '♦', '♣', '♠'][fi])
          : CardWidget(card: pile.last, width: cw, height: ch),
    );
  }

  Widget _emptySlot(double cw, double ch, {String? label}) => Container(
        width: cw,
        height: ch,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
          color: Colors.black.withValues(alpha: 0.15),
        ),
        child: label != null
            ? Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: cw * 0.4,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              )
            : null,
      );

  Widget _buildTableau(double cw, double ch, double gap) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int col = 0; col < 7; col++) ...[
            if (col > 0) SizedBox(width: gap),
            _buildColumn(col, cw, ch),
          ],
        ],
      ),
    );
  }

  Widget _buildColumn(int col, double cw, double ch) {
    final cards = _game.tableau[col];
    if (cards.isEmpty) {
      return GestureDetector(
        onTap: () => _onEmptyCol(col),
        child: _emptySlot(cw, ch),
      );
    }

    double totalH = ch;
    for (int i = 0; i < cards.length - 1; i++) {
      totalH += cards[i].isFaceUp ? 30.0 : 18.0;
    }

    return SizedBox(
      width: cw,
      height: totalH,
      child: Stack(
        children: [
          Positioned.fill(child: GestureDetector(onTap: () => _onEmptyCol(col))),
          for (int i = 0; i < cards.length; i++) _buildCard(col, i, cw, ch, cards),
        ],
      ),
    );
  }

  Widget _buildCard(int col, int i, double cw, double ch, List<PlayingCard> cards) {
    double top = 0;
    for (int j = 0; j < i; j++) {
      top += cards[j].isFaceUp ? 30.0 : 18.0;
    }
    return Positioned(
      top: top,
      left: 0,
      child: CardWidget(
        card: cards[i],
        width: cw,
        height: ch,
        isSelected: _isSelected(cards[i]),
        onTap: () => _onTableauCard(col, i),
        onLongPress: () => _onLongPressCard(col, i),
      ),
    );
  }
}

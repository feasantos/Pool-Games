import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/difficulty.dart';
import 'tic_tac_toe_game.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  bool _is1Player = true;
  Difficulty _difficulty = Difficulty.pierrote;
  TicTacToeGame? _game;
  int _kbCell = 4; // célula com foco do teclado (0-8), começa no centro

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;

    // Teclas 1-9: jogar diretamente na célula (linha-a-linha, 1=topo-esq, 9=baixo-dir)
    final pairs = [
      [LogicalKeyboardKey.digit1, LogicalKeyboardKey.numpad1],
      [LogicalKeyboardKey.digit2, LogicalKeyboardKey.numpad2],
      [LogicalKeyboardKey.digit3, LogicalKeyboardKey.numpad3],
      [LogicalKeyboardKey.digit4, LogicalKeyboardKey.numpad4],
      [LogicalKeyboardKey.digit5, LogicalKeyboardKey.numpad5],
      [LogicalKeyboardKey.digit6, LogicalKeyboardKey.numpad6],
      [LogicalKeyboardKey.digit7, LogicalKeyboardKey.numpad7],
      [LogicalKeyboardKey.digit8, LogicalKeyboardKey.numpad8],
      [LogicalKeyboardKey.digit9, LogicalKeyboardKey.numpad9],
    ];
    for (int i = 0; i < 9; i++) {
      if (key == pairs[i][0] || key == pairs[i][1]) {
        setState(() => _kbCell = i);
        if (_game != null) _handleTap(i);
        return true;
      }
    }

    // Setas: navegar o foco
    if (key == LogicalKeyboardKey.arrowLeft && _kbCell % 3 > 0) {
      setState(() => _kbCell--); return true;
    }
    if (key == LogicalKeyboardKey.arrowRight && _kbCell % 3 < 2) {
      setState(() => _kbCell++); return true;
    }
    if (key == LogicalKeyboardKey.arrowUp && _kbCell >= 3) {
      setState(() => _kbCell -= 3); return true;
    }
    if (key == LogicalKeyboardKey.arrowDown && _kbCell < 6) {
      setState(() => _kbCell += 3); return true;
    }
    if ((key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) &&
        _game != null) {
      _handleTap(_kbCell); return true;
    }
    return false;
  }

  void _startGame() {
    setState(() {
      _kbCell = 4;
      _game = TicTacToeGame(
        vsAi: _is1Player,
        difficulty: _difficulty,
      );
    });
  }

  void _handleTap(int index) {
    final game = _game!;
    final moved = game.tap(index);
    if (!moved) return;

    setState(() {});

    if (game.vsAi &&
        game.status == GameStatus.playing &&
        game.currentPlayer == Player.o) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        game.tap(game.aiMove);
        setState(() {});
      });
    }
  }

  void _reset() => setState(() { _game!.reset(); _kbCell = 4; });

  void _backToMenu() => setState(() => _game = null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo da Velha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _game == null ? () => Navigator.pop(context) : _backToMenu,
        ),
      ),
      body: _game == null ? _buildModeSelector() : _buildGame(),
    );
  }

  Widget _buildModeSelector() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Como quer jogar?',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Chip(
                  label: '1 Jogador',
                  selected: _is1Player,
                  color: AppTheme.accent,
                  onTap: () => setState(() => _is1Player = true),
                ),
                const SizedBox(width: 12),
                _Chip(
                  label: '2 Jogadores',
                  selected: !_is1Player,
                  color: AppTheme.accent,
                  onTap: () => setState(() => _is1Player = false),
                ),
              ],
            ),
            if (_is1Player) ...[
              const SizedBox(height: 28),
              Text(
                'Dificuldade',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textLight.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: Difficulty.values.map((d) {
                  return _Chip(
                    label: d.label,
                    selected: _difficulty == d,
                    color: _difficultyColor(d),
                    onTap: () => setState(() => _difficulty = d),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              _DifficultyHint(difficulty: _difficulty),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.textLight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Jogar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    final game = _game!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        _buildStatus(game),
        const SizedBox(height: 32),
        _buildBoard(game),
        const SizedBox(height: 32),
        TextButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh, color: AppTheme.accent),
          label: const Text('Reiniciar',
              style: TextStyle(color: AppTheme.accent, fontSize: 16)),
        ),
        Text(
          '1–9 jogar direto  •  ← ↑ → ↓ navegar  •  Enter confirmar',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textLight.withValues(alpha: 0.32),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatus(TicTacToeGame game) {
    final String text;
    final Color color;

    switch (game.status) {
      case GameStatus.xWins:
        text = game.vsAi ? 'Você venceu! 🎉' : 'X venceu!';
        color = Colors.greenAccent;
      case GameStatus.oWins:
        text = game.vsAi ? '${_difficulty.label} venceu!' : 'O venceu!';
        color = Colors.redAccent;
      case GameStatus.draw:
        text = 'Empate!';
        color = AppTheme.accent;
      case GameStatus.playing:
        final who = game.vsAi
            ? (game.currentPlayer == Player.x
                ? 'Sua vez (X)'
                : '${_difficulty.label} pensando...')
            : 'Vez de ${game.currentPlayer == Player.x ? "X" : "O"}';
        text = who;
        color = AppTheme.textLight;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey(text),
        style:
            TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildBoard(TicTacToeGame game) {
    final size = MediaQuery.of(context).size.width * 0.85;
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final isWinning = game.winningCells.contains(index);
            return _Cell(
              player: game.board[index],
              isWinning: isWinning,
              isKeyboardFocused: index == _kbCell,
              onTap: () => _handleTap(index),
            );
          },
        ),
      ),
    );
  }
}

Color _difficultyColor(Difficulty d) => switch (d) {
      Difficulty.sabricinha => const Color(0xFF4CAF50),
      Difficulty.alicinha => const Color(0xFFFFEB3B),
      Difficulty.pierrote => const Color(0xFFFF9800),
      Difficulty.feliposo => const Color(0xFFF44336),
    };

class _DifficultyHint extends StatelessWidget {
  final Difficulty difficulty;
  const _DifficultyHint({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final text = switch (difficulty) {
      Difficulty.sabricinha => 'Joga aleatório — moleza!',
      Difficulty.alicinha => 'Erra bastante, mas pensa às vezes.',
      Difficulty.pierrote => 'Dificilmente erra. Cuidado.',
      Difficulty.feliposo => 'Jogo perfeito. Impossível vencer.',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: _difficultyColor(difficulty).withValues(alpha: 0.8),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppTheme.textLight,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatefulWidget {
  final Player? player;
  final bool isWinning;
  final bool isKeyboardFocused;
  final VoidCallback onTap;

  const _Cell({
    required this.player,
    required this.isWinning,
    required this.isKeyboardFocused,
    required this.onTap,
  });

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(_Cell old) {
    super.didUpdateWidget(old);
    if (old.player == null && widget.player != null) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isWinning
        ? AppTheme.primary.withValues(alpha: 0.5)
        : widget.isKeyboardFocused
            ? Colors.white.withValues(alpha: 0.08)
            : AppTheme.surface;

    final borderColor = widget.isWinning
        ? AppTheme.accent
        : widget.isKeyboardFocused
            ? Colors.white70
            : AppTheme.primary;

    final borderWidth = (widget.isWinning || widget.isKeyboardFocused) ? 2.5 : 1.5;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: widget.player == null
            ? null
            : ScaleTransition(
                scale: _scale,
                child: Center(
                  child: Text(
                    widget.player == Player.x ? 'X' : 'O',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: widget.player == Player.x
                          ? Colors.blueAccent
                          : Colors.redAccent,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

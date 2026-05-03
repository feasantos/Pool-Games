import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';
import 'tic_tac_toe_game.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  bool? _vsAi;
  TicTacToeGame? _game;

  void _startGame(bool vsAi) {
    setState(() {
      _vsAi = vsAi;
      _game = TicTacToeGame(vsAi: vsAi);
    });
  }

  void _handleTap(int index) {
    final game = _game!;
    final moved = game.tap(index);
    if (!moved) return;

    setState(() {});

    if (game.vsAi && game.status == GameStatus.playing && game.currentPlayer == Player.o) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        game.tap(game.aiMove);
        setState(() {});
      });
    }
  }

  void _reset() {
    setState(() => _game!.reset());
  }

  void _backToMenu() {
    setState(() {
      _vsAi = null;
      _game = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo da Velha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _vsAi == null ? () => Navigator.pop(context) : _backToMenu,
        ),
      ),
      body: _vsAi == null ? _buildModeSelector() : _buildGame(),
    );
  }

  Widget _buildModeSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Como quer jogar?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textLight),
          ),
          const SizedBox(height: 40),
          _ModeButton(
            label: '1 Jogador',
            subtitle: 'Você vs IA',
            icon: Icons.smart_toy_outlined,
            onTap: () => _startGame(true),
          ),
          const SizedBox(height: 16),
          _ModeButton(
            label: '2 Jogadores',
            subtitle: 'Local no mesmo celular',
            icon: Icons.people_outline,
            onTap: () => _startGame(false),
          ),
        ],
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
          label: const Text('Reiniciar', style: TextStyle(color: AppTheme.accent, fontSize: 16)),
        ),
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
        text = game.vsAi ? 'IA venceu!' : 'O venceu!';
        color = Colors.redAccent;
      case GameStatus.draw:
        text = 'Empate!';
        color = AppTheme.accent;
      case GameStatus.playing:
        final who = game.vsAi
            ? (game.currentPlayer == Player.x ? 'Sua vez (X)' : 'IA pensando...')
            : 'Vez de ${game.currentPlayer == Player.x ? "X" : "O"}';
        text = who;
        color = AppTheme.textLight;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey(text),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
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
            onTap: () => _handleTap(index),
          );
        },
      ),
    ),
    );
  }
}

class _Cell extends StatefulWidget {
  final Player? player;
  final bool isWinning;
  final VoidCallback onTap;

  const _Cell({required this.player, required this.isWinning, required this.onTap});

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
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
        : AppTheme.surface;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isWinning ? AppTheme.accent : AppTheme.primary,
            width: widget.isWinning ? 2.5 : 1.5,
          ),
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
                      color: widget.player == Player.x ? Colors.blueAccent : Colors.redAccent,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.surface,
          side: const BorderSide(color: AppTheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accent, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: AppTheme.textLight.withValues(alpha: 0.6), fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

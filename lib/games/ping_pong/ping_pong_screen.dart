import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/difficulty.dart';
import 'ping_pong_game.dart';

class PingPongScreen extends StatefulWidget {
  const PingPongScreen({super.key});

  @override
  State<PingPongScreen> createState() => _PingPongScreenState();
}

class _PingPongScreenState extends State<PingPongScreen>
    with SingleTickerProviderStateMixin {
  final _game = PingPongGame();
  late Ticker _ticker;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration _) {
    if (!_initialized || _game.status != PingPongStatus.playing) return;
    _game.update();
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Ping Pong'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar',
            onPressed: () => setState(() => _game.restart()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildScoreBar(),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final size =
                    Size(constraints.maxWidth, constraints.maxHeight);
                if (!_initialized) {
                  _game.init(size.width, size.height);
                  _initialized = true;
                }
                return Stack(
                  children: [
                    CustomPaint(
                      painter: _GamePainter(_game),
                      size: size,
                    ),
                    if (_game.status == PingPongStatus.playing) ...[
                      if (_game.twoPlayer)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: size.height / 2,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanUpdate: (d) => setState(
                                () => _game.setP2Paddle(d.localPosition.dx)),
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: size.height / 2,
                        bottom: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: (d) => setState(
                              () => _game.setP1Paddle(d.localPosition.dx)),
                        ),
                      ),
                    ] else
                      _buildOverlay(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar() {
    final p2Label = _game.twoPlayer ? 'J2' : _game.difficulty.label;
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'J1   ${_game.p1Score}',
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_game.p2Score}   $p2Label',
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    final isIdle = _game.status == PingPongStatus.idle;
    final p1Wins = _game.status == PingPongStatus.p1Wins;

    final String title;
    final String buttonLabel;
    if (isIdle) {
      title = 'Ping Pong';
      buttonLabel = 'Iniciar';
    } else if (p1Wins) {
      title = _game.twoPlayer ? 'Jogador 1 Venceu!' : 'Você Venceu!';
      buttonLabel = 'Jogar Novamente';
    } else {
      title =
          _game.twoPlayer ? 'Jogador 2 Venceu!' : '${_game.difficulty.label} Venceu!';
      buttonLabel = 'Jogar Novamente';
    }

    final show1POptions = !_game.twoPlayer;

    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Seletor de modo (só no idle)
                if (isIdle)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Chip(
                          label: '1 Jogador',
                          selected: !_game.twoPlayer,
                          color: AppTheme.accent,
                          onTap: () =>
                              setState(() => _game.twoPlayer = false),
                        ),
                        const SizedBox(width: 12),
                        _Chip(
                          label: '2 Jogadores',
                          selected: _game.twoPlayer,
                          color: AppTheme.accent,
                          onTap: () =>
                              setState(() => _game.twoPlayer = true),
                        ),
                      ],
                    ),
                  ),

                // Seletor de dificuldade (modo 1P, idle e pós-jogo)
                if (show1POptions) ...[
                  Text(
                    'Dificuldade',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight.withValues(alpha: 0.55),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: Difficulty.values.map((d) {
                      return _Chip(
                        label: d.label,
                        selected: _game.difficulty == d,
                        color: _difficultyColor(d),
                        onTap: () =>
                            setState(() => _game.difficulty = d),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ] else
                  const SizedBox(height: 4),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.textLight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () =>
                      setState(() => isIdle ? _game.start() : _game.restart()),
                  child: Text(buttonLabel),
                ),
              ],
            ),
          ),
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

class _GamePainter extends CustomPainter {
  final PingPongGame game;
  _GamePainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0D3B1E),
    );

    final netPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + 12, size.height / 2),
        netPaint,
      );
      x += 22;
    }

    // P2 paddle (top — green)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            game.p2X, game.p2Top, game.paddleW, PingPongGame.paddleH),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF4CAF50),
    );

    // P1 paddle (bottom — yellow)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            game.p1X, game.p1Top, game.paddleW, PingPongGame.paddleH),
        const Radius.circular(6),
      ),
      Paint()..color = AppTheme.accent,
    );

    canvas.drawCircle(
      Offset(game.ballX, game.ballY),
      PingPongGame.ballR + 2,
      Paint()..color = Colors.white24,
    );
    canvas.drawCircle(
      Offset(game.ballX, game.ballY),
      PingPongGame.ballR,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _GamePainter _) => true;
}

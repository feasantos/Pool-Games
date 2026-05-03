import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/difficulty.dart';
import 'tetris_game.dart';

enum _Controls { touch, buttons }

class TetrisScreen extends StatefulWidget {
  const TetrisScreen({super.key});

  @override
  State<TetrisScreen> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen>
    with SingleTickerProviderStateMixin {
  final _game = TetrisGame();
  late Ticker _ticker;
  double _cellSize = 30;

  // Touch mode state
  double _dragAccX = 0;

  // Button mode state
  _Controls _controls = _Controls.touch;

  // DAS — Delayed Auto Shift (auto-repeat while holding ← / →)
  static const _dasDelay = 10; // frames before repeat starts (~167ms at 60fps)
  static const _dasRepeat = 4; // frames between repeats (~67ms)
  int _dasDir = 0; // -1 = left, 0 = none, 1 = right
  int _dasFrame = 0;

  @override
  void initState() {
    super.initState();
    _game.init();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration _) {
    if (_game.status == TetrisStatus.playing) {
      _game.update();
      if (_dasDir != 0) {
        _dasFrame++;
        if (_dasFrame >= _dasDelay &&
            (_dasFrame - _dasDelay) % _dasRepeat == 0) {
          if (_dasDir < 0) {
            _game.moveLeft();
          } else {
            _game.moveRight();
          }
        }
      }
    } else {
      _dasDir = 0;
      _dasFrame = 0;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ── Touch controls ──────────────────────────────────────────────

  void _onPanStart(DragStartDetails _) => _dragAccX = 0;

  void _onPanUpdate(DragUpdateDetails d) {
    if (_game.status != TetrisStatus.playing) return;
    _dragAccX += d.delta.dx;
    bool moved = false;
    while (_dragAccX >= _cellSize) {
      _game.moveRight();
      _dragAccX -= _cellSize;
      moved = true;
    }
    while (_dragAccX <= -_cellSize) {
      _game.moveLeft();
      _dragAccX += _cellSize;
      moved = true;
    }
    if (d.delta.dy > 0) {
      _game.setSoftDrop(true);
    } else if (d.delta.dy < -2) {
      _game.setSoftDrop(false);
    }
    if (moved) setState(() {});
  }

  void _onPanEnd(DragEndDetails d) {
    if (d.velocity.pixelsPerSecond.dy > 600) {
      setState(() => _game.hardDrop());
    }
    _game.setSoftDrop(false);
    _dragAccX = 0;
  }

  // ── Button controls ─────────────────────────────────────────────

  void _dasStart(int dir) {
    _dasDir = dir;
    _dasFrame = 0;
    if (dir < 0) {
      _game.moveLeft();
    } else {
      _game.moveRight();
    }
    setState(() {});
  }

  void _dasStop() {
    _dasDir = 0;
    _dasFrame = 0;
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tetris'),
        actions: [
          if (_game.status == TetrisStatus.playing)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reiniciar',
              onPressed: () => setState(() => _game.restart()),
            ),
        ],
      ),
      body: LayoutBuilder(builder: (ctx, constraints) {
        const buttonBarH = 80.0;
        final gameH = _controls == _Controls.buttons
            ? constraints.maxHeight - buttonBarH
            : constraints.maxHeight;

        final cellByW = constraints.maxWidth * 0.70 / TetrisGame.cols;
        final cellByH = gameH / TetrisGame.rows;
        _cellSize = min(cellByW, cellByH);
        final boardW = _cellSize * TetrisGame.cols;
        final boardH = _cellSize * TetrisGame.rows;

        return Column(
          children: [
            SizedBox(
              height: gameH,
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _controls == _Controls.touch
                        ? () => setState(() => _game.rotate())
                        : null,
                    onPanStart:
                        _controls == _Controls.touch ? _onPanStart : null,
                    onPanUpdate:
                        _controls == _Controls.touch ? _onPanUpdate : null,
                    onPanEnd:
                        _controls == _Controls.touch ? _onPanEnd : null,
                    child: SizedBox(
                      width: boardW,
                      height: gameH,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Stack(
                          children: [
                            CustomPaint(
                              painter: _BoardPainter(_game, _cellSize),
                              size: Size(boardW, boardH),
                            ),
                            if (_game.status != TetrisStatus.playing)
                              _buildOverlay(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _buildSidePanel()),
                ],
              ),
            ),
            if (_controls == _Controls.buttons) _buildButtonBar(),
          ],
        );
      }),
    );
  }

  Widget _buildOverlay() {
    final isIdle = _game.status == TetrisStatus.idle;
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isIdle ? 'Tetris' : 'Game Over',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isIdle) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Score: ${_game.score}',
                    style: const TextStyle(
                        color: AppTheme.textLight, fontSize: 15),
                  ),
                ],
                const SizedBox(height: 14),

                // Seletor de controles
                Text(
                  'Controles',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight.withValues(alpha: 0.55),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Chip(
                      label: 'Touch',
                      selected: _controls == _Controls.touch,
                      color: AppTheme.accent,
                      onTap: () =>
                          setState(() => _controls = _Controls.touch),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: 'Botões',
                      selected: _controls == _Controls.buttons,
                      color: AppTheme.accent,
                      onTap: () =>
                          setState(() => _controls = _Controls.buttons),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Seletor de dificuldade
                Text(
                  'Dificuldade',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight.withValues(alpha: 0.55),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: Difficulty.values
                      .map((d) => _Chip(
                            label: d.label,
                            selected: _game.difficulty == d,
                            color: _difficultyColor(d),
                            onTap: () =>
                                setState(() => _game.difficulty = d),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.textLight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => setState(() => _game.start()),
                  child: Text(isIdle ? 'Iniciar' : 'Jogar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonBar() {
    return Container(
      height: 80,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Movimento horizontal
          Row(
            children: [
              _GameButton(
                icon: Icons.arrow_back,
                onPress: () => _dasStart(-1),
                onRelease: _dasStop,
              ),
              const SizedBox(width: 10),
              _GameButton(
                icon: Icons.arrow_forward,
                onPress: () => _dasStart(1),
                onRelease: _dasStop,
              ),
            ],
          ),
          // Ações
          Row(
            children: [
              _GameButton(
                icon: Icons.rotate_right,
                onTap: () => setState(() => _game.rotate()),
              ),
              const SizedBox(width: 10),
              _GameButton(
                icon: Icons.arrow_downward,
                onPress: () => _game.setSoftDrop(true),
                onRelease: () => _game.setSoftDrop(false),
              ),
              const SizedBox(width: 10),
              _GameButton(
                icon: Icons.keyboard_double_arrow_down,
                onTap: () => setState(() => _game.hardDrop()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
      child: Column(
        children: [
          Text(
            'NEXT',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textLight.withValues(alpha: 0.55),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _NextPiece(game: _game, cellSize: _cellSize * 0.65),
          const SizedBox(height: 24),
          _InfoTile(label: 'SCORE', value: '${_game.score}'),
          const SizedBox(height: 16),
          _InfoTile(label: 'NÍVEL', value: '${_game.level}'),
          const SizedBox(height: 16),
          _InfoTile(label: 'LINHAS', value: '${_game.linesCleared}'),
        ],
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────

class _GameButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onPress;
  final VoidCallback? onRelease;

  const _GameButton({
    required this.icon,
    this.onTap,
    this.onPress,
    this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: onPress != null ? (_) => onPress!() : null,
      onTapUp: onRelease != null ? (_) => onRelease!() : null,
      onTapCancel: onRelease,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primary, width: 1.5),
        ),
        child: Icon(icon, color: AppTheme.textLight, size: 26),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textLight.withValues(alpha: 0.55),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
          ),
        ),
      ],
    );
  }
}

class _NextPiece extends StatelessWidget {
  final TetrisGame game;
  final double cellSize;
  const _NextPiece({required this.game, required this.cellSize});

  @override
  Widget build(BuildContext context) {
    if (game.status == TetrisStatus.idle) {
      return SizedBox(width: cellSize * 4, height: cellSize * 4);
    }
    return CustomPaint(
      size: Size(cellSize * 4, cellSize * 4),
      painter: _NextPainter(game, cellSize),
    );
  }
}

class _NextPainter extends CustomPainter {
  final TetrisGame game;
  final double cellSize;
  _NextPainter(this.game, this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Color(game.nextPieceColor);
    for (final cell in game.nextCells) {
      canvas.drawRect(
        Rect.fromLTWH(
          cell[1] * cellSize,
          cell[0] * cellSize,
          cellSize - 1,
          cellSize - 1,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NextPainter _) => true;
}

class _BoardPainter extends CustomPainter {
  final TetrisGame game;
  final double cs;

  _BoardPainter(this.game, this.cs);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A0A0A),
    );

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 0.5;
    for (int r = 0; r <= TetrisGame.rows; r++) {
      canvas.drawLine(
          Offset(0, r * cs), Offset(size.width, r * cs), gridPaint);
    }
    for (int c = 0; c <= TetrisGame.cols; c++) {
      canvas.drawLine(
          Offset(c * cs, 0), Offset(c * cs, size.height), gridPaint);
    }

    for (int r = 0; r < TetrisGame.rows; r++) {
      for (int c = 0; c < TetrisGame.cols; c++) {
        final color = game.board[r][c];
        if (color != null) _drawBlock(canvas, r, c, Color(color));
      }
    }

    if (game.status == TetrisStatus.playing) {
      final ghost = game.ghostRow;
      if (ghost != game.pieceRow) {
        final outlinePaint = Paint()
          ..color = Color(game.pieceColor).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        for (final cell in game.currentCells) {
          final r = ghost + cell[0];
          final c = game.pieceCol + cell[1];
          if (r >= 0 && r < TetrisGame.rows && c >= 0 && c < TetrisGame.cols) {
            canvas.drawRect(
              Rect.fromLTWH(c * cs + 1, r * cs + 1, cs - 2, cs - 2),
              outlinePaint,
            );
          }
        }
      }

      for (final cell in game.currentCells) {
        final r = game.pieceRow + cell[0];
        final c = game.pieceCol + cell[1];
        if (r >= 0) _drawBlock(canvas, r, c, Color(game.pieceColor));
      }
    }
  }

  void _drawBlock(Canvas canvas, int row, int col, Color color) {
    final rect =
        Rect.fromLTWH(col * cs + 0.5, row * cs + 0.5, cs - 1, cs - 1);
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(
      Rect.fromLTWH(col * cs + 0.5, row * cs + 0.5, cs - 1, 2),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPainter _) => true;
}

Color _difficultyColor(Difficulty d) => switch (d) {
      Difficulty.sabricinha => const Color(0xFF4CAF50),
      Difficulty.alicinha   => const Color(0xFFFFEB3B),
      Difficulty.pierrote   => const Color(0xFFFF9800),
      Difficulty.feliposo   => const Color(0xFFF44336),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
